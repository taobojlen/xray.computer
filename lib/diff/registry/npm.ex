defmodule Diff.Registry.Npm do
  alias Diff.{Registry, Util}
  use HTTPoison.Base

  @behaviour Registry

  @impl HTTPoison.Base
  def process_request_url(url) do
    "https://registry.npmjs.com" <> url
  end

  @impl HTTPoison.Base
  def process_response_body(body) do
    body
    |> Jason.decode!()
  end

  @impl Registry
  def search(query) do
    case get("/-/v1/search?size=10&text=" <> query) do
      {:ok, response} ->
        {:ok,
         response.body["objects"] |> Enum.map(fn obj -> get_in(obj, ["package", "name"]) end)}

      other ->
        other
    end
  end

  @impl Registry
  def versions(package) do
    case get("/" <> package) do
      # TODO: better sorting
      {:ok, response} ->
        {:ok, maybe_get_versions(response.body)}

      {:error, error} ->
        {:error, error}
    end
  end

  @impl Registry
  def get_package(package, version) do
    tarball_path = Util.tmp_path("tarball")

    with {:ok, url} <- get_tarball_url(package, version) do
      File.touch!(tarball_path)
      # Download as a stream
      get_stream!(url)
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

  defp get_stream!(url, timeout \\ 30_000) do
    Stream.resource(
      fn -> HTTPoison.get!(url, %{}, stream_to: self(), async: :once) end,
      fn %HTTPoison.AsyncResponse{id: id} = resp ->
        receive do
          %HTTPoison.AsyncStatus{id: ^id} ->
            HTTPoison.stream_next(resp)
            {[], resp}

          %HTTPoison.AsyncHeaders{id: ^id} ->
            HTTPoison.stream_next(resp)
            {[], resp}

          %HTTPoison.AsyncChunk{id: ^id, chunk: chunk} ->
            HTTPoison.stream_next(resp)
            {[chunk], resp}

          %HTTPoison.AsyncEnd{id: ^id} ->
            {:halt, resp}
        after
          timeout -> raise "download tarball timeout"
        end
      end,
      fn resp -> :hackney.stop_async(resp.id) end
    )
  end

  defp maybe_get_versions(nil) do
    []
  end

  defp maybe_get_versions(body) do
    case body do
      %{"versions" => versions} ->
        versions |> Map.keys() |> Enum.sort() |> Enum.reverse()

      _ ->
        []
    end
  end
end
