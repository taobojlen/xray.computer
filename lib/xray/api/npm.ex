defmodule Xray.Api.Npm do
  alias Xray.Api.{CachedApi, StreamingApi}

  @behaviour StreamingApi.Contract
  @behaviour CachedApi.Contract

  @impl CachedApi.Contract
  def get(url) do
    CachedApi.get("https://registry.npmjs.com/" <> url)
  end

  @impl StreamingApi.Contract
  def get_stream!(url) do
    StreamingApi.get_stream!(url, 120_000)
  end
end
