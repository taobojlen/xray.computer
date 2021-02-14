defmodule Xray.Util do
  # sobelow_skip ["Traversal"]
  def tmp_path(prefix \\ "") do
    tmp_folder = Path.join([System.tmp_dir!(), "xray"])

    if !File.dir?(tmp_folder) do
      File.mkdir!(tmp_folder)
    end

    random_string = Base.encode16(:crypto.strong_rand_bytes(4))
    Path.join([tmp_folder, prefix <> random_string])
  end

  @doc """
  Returns a map containing all files and their contents from the compressed tar archive.
  """
  def extract_tar_from_binary(binary) do
    with {:ok, files} <- :erl_tar.extract({:binary, binary}, [:memory, :compressed]) do
      files
      |> Enum.map(fn {filename, content} -> {to_string(filename), content} end)
      |> Map.new()
    end
  end

  @doc """
  Download as a stream.
  """
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
end
