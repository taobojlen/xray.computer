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
  Given a path to a .tgz on the filesystem, extracts it to
  `destination_folder`.
  """
  @spec extract_tgz(String.t(), String.t()) :: :ok | {:error, any}
  def extract_tgz(tarball_path, destination_folder) do
    with {:ok, compressed_content} <- File.read(tarball_path),
         content <- :zlib.gunzip(compressed_content),
         {:ok, files} <- :erl_tar.extract({:binary, content}, [:memory, :compressed]) do
      files
      |> Enum.map(fn {filename, content} -> {to_string(filename), content} end)
      |> Map.new()
      |> Enum.each(fn {file, content} ->
        file = String.replace(file, ~r"^package\/", "")
        file = Path.join([destination_folder, file])

        file |> Path.dirname() |> File.mkdir_p!()

        File.write!(file, content)
      end)
    else
      {:error, error} -> {:error, error}
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

  @doc """
  Sorter for SemVer-compliant strings.
  """
  def compare_versions(first, second) do
    with {:ok, first} <- Version.parse(first), {:ok, second} <- Version.parse(second) do
      Version.compare(first, second) == :gt
    else
      _error -> false
    end
  end
end
