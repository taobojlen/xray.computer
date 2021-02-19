defmodule Xray.Api.Npm do
  use HTTPoison.Base
  alias Xray.{Api, Util}

  @behaviour Api.StreamingApi
  @cache :api_cache

  @impl HTTPoison.Base
  def process_request_url(url) do
    "https://registry.npmjs.com" <> url
  end

  @impl HTTPoison.Base
  def process_response_body(body) do
    body
    |> Jason.decode!()
  end

  @impl HTTPoison.Base
  def get(url) do

    case Cachex.get(@cache, url) do
      {:ok, nil} ->
        case super(url) do
          {:ok, response} ->
            Cachex.put(@cache, url, response, ttl: :timer.hours(24))
            {:ok, response}

          other ->
            other
        end

      {:ok, response} ->
        {:ok, response}

      {:error, e} ->
        {:error, "Cache call failed"}
    end
  end

  @impl Api.StreamingApi
  def get_stream!(url) do
    Util.get_stream!(url, 120_000)
  end
end
