defmodule Xray.Api.CachedApi do
  @behaviour __MODULE__.Contract

  @cache :api_cache
  @httpoison Application.compile_env!(:xray, :httpoison)

  def get(url) do
    case Cachex.get(@cache, url) do
      {:ok, nil} ->
        case @httpoison.get(url) do
          {:ok, response} ->
            Cachex.put(@cache, url, response, ttl: :timer.hours(24))
            {:ok, response}

          other ->
            other
        end

      {:ok, response} ->
        {:ok, response}

      {:error, _error} ->
        {:error, "Cache call failed"}
    end
  end

  defmodule Contract do
    @callback get(String.t()) :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  end
end
