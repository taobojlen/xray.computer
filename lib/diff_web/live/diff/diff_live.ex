defmodule DiffWeb.DiffLive do
  use DiffWeb, :live_view
  alias Diff.{Repo, Registry}
  alias Diff.Package
  import Ecto.Query

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, query: "", results: [], package: %{})}
  end

  @impl true
  def handle_event("suggest", %{"q" => query}, socket) do
    with {:ok, packages} <- Registry.Npm.search(query) do
      {:noreply, assign(socket, results: packages, query: query)}
    end
  end

  @impl true
  def handle_event("select", %{"q" => query}, socket) do
    case Repo.one(from p in Package, select: p.name, where: p.name == ^query) do
      package ->
        {:noreply, assign(socket, package: package, query: query)}
    end
  end
end
