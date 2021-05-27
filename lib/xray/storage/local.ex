defmodule Xray.Storage.Local do
  @behaviour Xray.Storage.Repo

  @impl true
  # sobelow_skip ["Traversal"]
  def get(key) do
    case(File.read(path(key))) do
      {:ok, content} -> content
      {:error, _} -> nil
    end
  end

  @impl true
  def get_to_filesystem(key, destination_path) do
    path = path(key)
    File.cp!(path, destination_path)
  end

  @impl true
  def list(prefix) do
    path(prefix <> "/**")
    |> Path.wildcard(match_dot: true)
    |> Enum.filter(&File.regular?/1)
    |> Enum.map(&Path.relative_to(&1, root()))
  end

  @impl true
  # sobelow_skip ["Traversal"]
  def put(key, content) do
    path = path(key)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, content)
  end

  @impl true
  def put_from_filesystem(key, source_path) do
    path = path(key)
    File.cp!(source_path, path)
  end

  @spec path(String.t()) :: binary()
  defp path(key) do
    if String.contains?(key, "..") do
      raise "Invalid storage key: '#{key}'"
    end

    Path.join(root(), key)
  end

  @spec root() :: binary()
  defp root do
    Application.get_env(:xray, :tmp_dir)
  end
end
