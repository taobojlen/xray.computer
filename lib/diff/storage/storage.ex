defmodule Diff.Storage do
  @type key :: String.t()
  @type prefix :: String.t()

  defmodule Repo do
    @type key :: String.t()
    @type prefix :: String.t()

    @callback get(key) :: binary() | nil
    @callback list(prefix) :: [key]
    @callback put(key, binary()) :: term()
  end

  @spec get(key) :: binary() | nil
  def get(key) do
    repo = impl()
    repo.get(key)
  end

  @spec list(prefix) :: binary() | nil
  def list(prefix) do
    repo = impl()
    repo.list(prefix)
  end

  @spec put(key, binary()) :: term()
  def put(key, content) do
    repo = impl()
    repo.put(key, content)
  end

  defp impl() do
    [implementation: implementation, name: _name] = Application.get_env(:diff, :bucket)
    implementation
  end
end
