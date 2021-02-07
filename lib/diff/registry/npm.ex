defmodule Diff.Registry.Npm do
  @moduledoc """
  A Registry module to interface with npm.
  """
  alias Diff.{Registry, Util}
  alias Diff.Packages.{Package, Version}
  alias Ecto.Changeset
  use HTTPoison.Base

  # TODO: cache responses from npm

  @behaviour Registry.API

  @impl HTTPoison.Base
  def process_request_url(url) do
    "https://registry.npmjs.com" <> url
  end

  @impl HTTPoison.Base
  def process_response_body(body) do
    body
    |> Jason.decode!()
  end

  @impl true
  def search(query) do
    case get("/-/v1/search?size=10&text=" <> query) do
      {:ok, response} ->
        {:ok,
         response.body["objects"] |> Enum.map(fn obj -> get_in(obj, ["package", "name"]) end)}

      other ->
        other
    end
  end

  @impl true
  def get_package(name) do
    case get("/" <> name) do
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

      {:error, error} ->
        {:error, error}
    end
  end

  @impl true
  def get_versions(package) do
    case get("/" <> package) do
      {:ok, response} ->
        {:ok, maybe_get_versions(response.body)}

      {:error, error} ->
        {:error, error}
    end
  end

  @impl true
  def get_source(package, version) do
    tarball_path = Util.tmp_path("tarball")

    with {:ok, url} <- get_tarball_url(package, version) do
      File.touch!(tarball_path)

      Util.get_stream!(url)
      |> Stream.into(File.stream!(tarball_path))
      |> Stream.run()

      folder_path = Util.tmp_path("package")
      File.mkdir!(folder_path)

      tarball_path
      |> File.read!()
      |> :zlib.gunzip()
      |> Diff.Util.extract_tar_from_binary()
      |> Enum.each(fn {file, content} ->
        file = String.replace(file, ~r"^package\/", "")
        file = Path.join([folder_path, file])

        file |> Path.dirname() |> File.mkdir_p!()

        File.write!(file, content)
      end)

      File.rm!(tarball_path)

      {:ok, folder_path}
    end
  end

  defp get_tarball_url(package, version) do
    case get("/" <> package) do
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
      %{"time" => time} ->
        time
        |> Enum.filter(fn {version, _released_at} ->
          not Enum.member?(["created", "modified"], version)
        end)
        |> Enum.map(fn {version, released_at} ->
          with {:ok, timestamp, _offset} <- DateTime.from_iso8601(released_at) do
            %Version{
              version: version,
              released_at: timestamp |> DateTime.truncate(:second)
            }
          end
        end)
        |> Enum.sort_by(fn %{released_at: released_at} -> released_at end, DateTime)
        |> Enum.reverse()

      _ ->
        []
    end
  end
end
