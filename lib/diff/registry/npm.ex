defmodule Diff.Registry.Npm do
  alias Diff.Registry
  use Tesla

  @behaviour Registry

  plug Tesla.Middleware.BaseUrl, "https://registry.npmjs.org"
  plug Tesla.Middleware.JSON

  @impl Registry
  def search(query) do
    case get("/-/v1/search", query: [text: query, size: 10]) do
      {:ok, response} ->
        {:ok,
         response.body["objects"] |> Enum.map(fn obj -> get_in(obj, ["package", "name"]) end)}

      other ->
        other
    end
  end

  @impl Registry
  def versions(package) do
    case get("/" <> package) do
      {:ok, response} ->
        {:ok, response.body["versions"] |> Map.keys()}
    end
  end
end
