defmodule Xray.Source.SourceFetcher do
  use Oban.Worker,
    queue: :source_fetcher,
    unique: [period: :infinity]

  use GenServer

  require Logger
  alias Xray.{Packages, Source, Storage}

  defmodule Counter do
    def start_link(val) do
      Agent.start_link(fn -> val end)
    end

    def value(counter) do
      Agent.get(counter, fn val -> val end)
    end

    def inc(counter) do
      Agent.update(counter, fn val -> val + 1 end)
    end
  end

  @impl GenServer
  def init(:ok) do
    {:ok, counter} = Counter.start_link(0)
    state = %{total_files: nil, counter: counter}
    {:ok, state}
  end

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    version = Packages.get_version!(id)
    package = Packages.get_package!(version.package_id)

    Logger.info(
      "Getting source for #{package.registry} package #{package.name} v#{version.version}"
    )

    case store_files(package, version) do
      {:ok, files_list_key, tarball_key} ->
        Packages.update_version(version, %{source_key: files_list_key, tarball_key: tarball_key})

        Source.notify_found_source(
          package.registry,
          package.name,
          version.version,
          version.id
        )

      {:error, error} ->
        Source.notify_error(package.registry, package.name, version.version, error)
    end

    :ok
  end

  # sobelow_skip ["Traversal"]
  defp store_files(package, version) do
    registry = get_registry()

    case registry.get_source(package.registry, package.name, version.version) do
      {:ok, tmp_path, tarball_path} ->
        files =
          Path.join([tmp_path, "**"])
          |> Path.wildcard(match_dot: true)
          |> Enum.filter(&File.regular?/1)
          |> Enum.reduce(%{}, fn path, acc ->
            filename = Path.relative_to(path, tmp_path)
            Map.put(acc, filename, path)
          end)

        Logger.debug(
          "Storing #{files |> Map.keys() |> Kernel.length()} files for #{package.registry} #{package.name} v#{version.version}"
        )

        {:ok, pid} = GenServer.start_link(__MODULE__, :ok)
        Source.notify_progress(package.registry, package.name, version.version, 0)

        send(pid, {:got_file_count, map_size(files)})

        upload_file = fn {filename, path} ->
          content = File.read!(path)
          key = get_storage_key(package, version, filename)
          Storage.put(key, content)
          send(pid, {:uploaded_file, package.registry, package.name, version.version})
        end

        files
        |> Task.async_stream(upload_file, max_concurrency: 20, timeout: 60_000)
        |> Stream.run()

        tarball_key = get_tarball_key(package, version)
        Storage.put_from_filesystem(tarball_key, tarball_path)

        File.rm_rf(tmp_path)
        File.rm(tarball_path)

        files =
          Enum.reduce(files, %{}, fn {filename, _path}, acc ->
            key = get_storage_key(package, version, filename)
            Map.put(acc, filename, key)
          end)

        {:ok, save_files_list(files, package, version), tarball_key}

      {:error, error} ->
        {:error, error}
    end
  end

  @impl GenServer
  def handle_info(
        {:uploaded_file, registry, package, version},
        %{total_files: total_files} = state
      ) do
    Counter.inc(state.counter)
    progress = Counter.value(state.counter) / total_files
    Source.notify_progress(registry, package, version, progress)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info({:got_file_count, count}, state) do
    state = Map.put(state, :total_files, count)
    {:noreply, state}
  end

  defp save_files_list(files, package, version) do
    content = Jason.encode!(files)
    key = Source.get_files_list_key(package.registry, package.name, version.version)
    Storage.put(key, content)
    key
  end

  defp get_storage_key(package, version, filename) do
    Source.get_storage_key(package.registry, package.name, version.version) <> "/" <> filename
  end

  defp get_tarball_key(package, version) do
    Source.get_storage_key(package.registry, package.name, version.version) <> ".tgz"
  end

  defp get_registry do
    Application.get_env(:xray, :registry)
  end
end
