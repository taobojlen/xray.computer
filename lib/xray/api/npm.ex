defmodule Xray.Api.Npm do
  use HTTPoison.Base
  alias Xray.{Api, Util}

  @behaviour Api.StreamingApi

  @impl HTTPoison.Base
  def process_request_url(url) do
    "https://registry.npmjs.com" <> url
  end

  @impl HTTPoison.Base
  def process_response_body(body) do
    body
    |> Jason.decode!()
  end

  @impl Api.StreamingApi
  def get_stream!(url) do
    Util.get_stream!(url, 120_000)
  end
end
