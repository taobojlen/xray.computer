defmodule Xray.Source.SourceFetcher do
  use Oban.Worker, queue: :source_fetcher
  alias Xray.{Packages, Source, Storage}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => id}}) do
    version = Packages.get_version!(id)
    package = Packages.get_package!(version.package_id)
    files_list_key = store_files(package, version)
    Packages.update_version(version, %{source_key: files_list_key})
    Source.notify_found_source(package.registry, package.name, version.version, files_list_key)
    :ok
  end

  # sobelow_skip ["Traversal"]
  defp store_files(package, version) do
    registry = get_registry()

    case registry.get_source(package.registry, package.name, version.version) do
      {:ok, tmp_path} ->
        files =
          Path.join([tmp_path, "**"])
          |> Path.wildcard(match_dot: true)
          |> Enum.filter(&File.regular?/1)
          |> Enum.reduce(%{}, fn path, acc ->
            filename = Path.relative_to(path, tmp_path)
            Map.put(acc, filename, path)
          end)

        files
        |> Enum.each(fn {filename, path} ->
          content = File.read!(path)
          key = get_storage_key(package, version, filename)
          Storage.put(key, content)
        end)

        File.rm_rf!(tmp_path)

        files =
          Enum.reduce(files, %{}, fn {filename, _path}, acc ->
            key = get_storage_key(package, version, filename)
            Map.put(acc, filename, key)
          end)

        save_files_list(files, package, version)

      {:error, error} ->
        raise error
    end
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

  defp get_registry do
    Application.get_env(:xray, :registry)
  end
end
