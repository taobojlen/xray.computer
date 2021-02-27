defmodule Xray.Api.Npm do
  alias Xray.Api.{CachedJsonApi, StreamingApi}

  @behaviour StreamingApi.Contract
  @behaviour CachedJsonApi.Contract

  @impl CachedJsonApi.Contract
  def get(url) do
    case CachedJsonApi.get("https://registry.npmjs.com/" <> url) do
      {:ok, response} ->
        {:ok, process_response(response)}

      other ->
        other
    end
  end

  @impl StreamingApi.Contract
  def get_stream!(url) do
    StreamingApi.get_stream!(url, 120_000)
  end

  defp process_response(response) do
    body = response.body

    response
    |> Map.delete(:body)
    |> Map.put(:body, Jason.decode!(body))
  end
end
