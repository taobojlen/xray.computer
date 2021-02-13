defmodule Xray.Api.StreamingApi do
  @callback get_stream!(String.t()) :: Stream.t()
end
