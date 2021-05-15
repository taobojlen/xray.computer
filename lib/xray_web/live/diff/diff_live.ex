defmodule XrayWeb.DiffLive do
  alias Xray.Packages.Package
  alias Xray.{Registry, Repo}
  use XrayWeb, :live_view
  import Ecto.Query

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: [], package: %{}, page_title: "Diff")}
  end

  @impl true
  def handle_event("suggest", %{"q" => query}, socket) do
    packages = Registry.search("npm", query)
    {:noreply, assign(socket, results: packages, query: query)}
  end

  @impl true
  def handle_event("select", %{"q" => query}, socket) do
    case Repo.one(from p in Package, select: p.name, where: p.name == ^query) do
      package ->
        {:noreply, assign(socket, package: package, query: query)}
    end
  end
end
