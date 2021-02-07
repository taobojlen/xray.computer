defmodule Diff.Storage.Local do
  @behaviour Diff.Storage.Repo

  @impl true
  def get(key) do
    case(File.read(path(key))) do
      {:ok, content} -> content
      {:error, _} -> nil
    end
  end

  @impl true
  def list(prefix) do
    path(prefix <> "/**")
    |> Path.wildcard(match_dot: true)
    |> Enum.filter(&File.regular?/1)
    |> Enum.map(&Path.relative_to(&1, root()))
  end

  @impl true
  def put(key, content) do
    path = path(key)
    File.mkdir_p!(Path.dirname(path))
    File.write!(path, content)
  end

  @spec path(String.t()) :: binary()
  defp path(key) do
    Path.join(root(), key)
  end

  @spec root() :: binary()
  defp root() do
    Application.get_env(:diff, :tmp_dir)
  end
end
