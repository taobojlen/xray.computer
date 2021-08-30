defmodule Xray.Api.StreamingApi do
  @behaviour __MODULE__.Contract

  def get_stream!(url, timeout \\ 30_000) do
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
          timeout -> raise "download timeout"
        end
      end,
      fn resp -> :hackney.stop_async(resp.id) end
    )
  end

  defmodule Contract do
    @callback get_stream!(String.t()) :: Enumerable.t()
  end
end
