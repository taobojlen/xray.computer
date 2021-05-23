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
  Sorts a list of SemVer-compliant strings in decreasing order.
  Any version strings that aren't compliant may end up in weird places in the order.
  """
  @spec sort_versions([String.t()]) :: [String.t()]
  def sort_versions(versions) do
    versions
    |> Enum.sort(&compare_versions/2)
  end

  def beautify_datetime(nil) do
    nil
  end

  def beautify_datetime(%{year: year, month: month, day: day}) do
    month = month |> Integer.to_string() |> String.pad_leading(2, "0")
    day = day |> Integer.to_string() |> String.pad_leading(2, "0")
    "#{year}-#{month}-#{day}"
  end

  defp compare_versions(first, second) do
    with {:ok, first} <- Version.parse(first), {:ok, second} <- Version.parse(second) do
      Version.compare(first, second) == :gt
    else
      _error -> false
    end
  end
end
