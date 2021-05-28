defmodule Xray.Storage.S3 do
  alias ExAws.S3

  @behaviour Xray.Storage.Repo
  @bucket Application.compile_env(:xray, :bucket)[:name]

  @impl true
  def get(key) do
    S3.get_object(@bucket, key) |> ExAws.request!() |> Map.get(:body)
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
    path
    |> S3.Upload.stream_file()
    |> S3.upload(@bucket, key)
    |> ExAws.request!()
  end

  @impl true
  def get_to_filesystem(key, path) do
    @bucket
    |> S3.download_file(key, path)
    |> ExAws.request!()
  end
end
