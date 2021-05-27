defmodule Xray.Storage do
  @type key :: String.t()
  @type prefix :: String.t()

  defmodule Repo do
    @type key :: String.t()
    @type prefix :: String.t()

    @callback get(key) :: binary() | nil
    @callback list(prefix) :: [key]
    @callback put(key, binary()) :: term()
    @callback put_from_filesystem(key, String.t()) :: term()
    @callback get_to_filesystem(key, String.t()) :: term()
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

  @spec put_from_filesystem(key, String.t()) :: term()
  def put_from_filesystem(key, path) do
    repo = impl()
    repo.put_from_filesystem(key, path)
  end

  @spec get_to_filesystem(key, String.t()) :: term()
  def get_to_filesystem(key, path) do
    repo = impl()
    repo.get_to_filesystem(key, path)
  end

  defp impl do
    [implementation: implementation, name: _name] = Application.get_env(:xray, :bucket)
    implementation
  end
end
