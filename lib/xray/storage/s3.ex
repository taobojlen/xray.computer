defmodule Xray.Storage.S3 do
  alias ExAws.S3

  require Logger

  @behaviour Xray.Storage.Repo
  @bucket Application.compile_env(:xray, :bucket)[:name]

  @impl true
  def get(key) do
    Logger.debug("Getting #{key} from S3")

    case S3.get_object(@bucket, key) |> ExAws.request() do
      {:ok, result} -> Map.get(result, :body)
      {:error, {:http_error, 404, _response}} -> nil
    end
  end

  @impl true
  def list(prefix) do
    S3.list_objects(@bucket, prefix: prefix) |> ExAws.request!()
  end

  @impl true
  def put(key, content) do
    S3.put_object(@bucket, key, content) |> ExAws.request!()
  end

  @impl true
  def put_from_filesystem(key, path) do
    case path
         |> S3.Upload.stream_file()
         |> S3.upload(@bucket, key)
         |> ExAws.request() do
      {:ok, %{status_code: 200}} -> :ok
      {:error, error} -> {:error, error}
    end
  end

  @impl true
  def get_to_filesystem(key, path) do
    Logger.debug("Downloading #{key} to #{path}")

    case @bucket
         |> S3.download_file(key, path)
         |> ExAws.request() do
      {:ok, _result} -> :ok
      {:error, error} -> {:error, error}
    end
  end
end
