defmodule Xray.Registry.Npm do
  @moduledoc """
  A Registry module to interface with npm.
  """
  alias Ecto.Changeset
  alias Xray.{Registry, Util}
  alias Xray.Packages.{Package, Version}

  require Logger

  @behaviour Registry.Behaviour

  @api Application.compile_env!(:xray, :npm_api)

  @impl true
  def get_packages! do
    path = Jaxon.Path.parse!("$.rows[*].key")

    @api.get_stream!("https://replicate.npmjs.com/_all_docs")
    |> Jaxon.Stream.from_enumerable()
    |> Jaxon.Stream.query(path)
  end

  @impl true
  def get_package(name) do
    case @api.get(name) do
      {:ok, %{body: %{"name" => returned_name}}} ->
        if returned_name == name do
          with {:ok, versions} <- get_versions(name) do
            changeset =
              %Package{}
              |> Package.changeset(%{
                name: name,
                registry: "npm",
                versions_updated_at: DateTime.utc_now()
              })
              |> Changeset.put_assoc(:versions, versions)

            {:ok, changeset}
          end
        else
          {:error, "package does not exist"}
        end

      {:ok, %{body: %{"error" => error}}} ->
        {:error, error}

      {:error, error} ->
        {:error, error}
    end
  end

  @impl true
  def get_versions(package) do
    case @api.get(package) do
      {:ok, response} ->
        {:ok, maybe_get_versions(response.body)}

      {:error, error} ->
        {:error, error}
    end
  end

  @impl true
  # sobelow_skip ["Traversal"]
  def get_source(package, version) do
    tarball_path = Path.join([Util.tmp_path(), "tarball.tgz"])

    with {:ok, url} <- get_tarball_url(package, version) do
      File.touch!(tarball_path)

      @api.get_stream!(url)
      |> Stream.into(File.stream!(tarball_path))
      |> Stream.run()

      folder_path = Util.tmp_path("package")
      Util.extract_tgz(tarball_path, folder_path)

      {:ok, folder_path, tarball_path}
    end
  end

  @impl true
  def format(path) do
    Logger.debug("npx prettier --write #{path}")

    case System.cmd(
           "npx",
           [
             "prettier",
             "--write",
             path
           ],
           stderr_to_stdout: true
         ) do
      {_result, 0} -> :ok
      {output, _exit_code} -> {:error, output}
    end
  end

  defp get_tarball_url(package, version) do
    case @api.get(package) do
      {:ok, response} ->
        case get_in(response.body, ["versions", version, "dist", "tarball"]) do
          nil -> {:error, "Couldn't find tarball URL"}
          url -> {:ok, url}
        end

      {:error, _error} ->
        {:error, "Failed to get tarball URL"}
    end
  end

  defp maybe_get_versions(nil) do
    []
  end

  defp maybe_get_versions(body) do
    case body do
      %{"versions" => versions} ->
        Map.keys(versions)
        |> Enum.map(fn version ->
          released_at = get_version_released_at(version, body)

          with {:ok, timestamp, _offset} <- DateTime.from_iso8601(released_at) do
            %Version{
              version: version,
              released_at: timestamp |> DateTime.truncate(:second)
            }
          end
        end)
        |> Enum.sort_by(&Map.get(&1, :version), &Util.compare_versions/2)

      _ ->
        []
    end
  end

  defp get_version_released_at(version, body) do
    case body do
      %{"time" => time} ->
        Map.get(time, version)

      _ ->
        nil
    end
  end
end
