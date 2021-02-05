defmodule DiffWeb.SelectSourceLive do
  alias Diff.{Packages, Registry, Repo}
  import Ecto.Query
  use DiffWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, version: nil, versions: [], package: nil, suggestions: [])}
  end

  @impl true
  def handle_event("type", %{"p" => package}, socket) do
    versions_task = Task.async(fn -> get_versions(package) end)
    suggestions_task = Task.async(fn -> get_suggestions(package) end)

    case {Task.await(versions_task), Task.await(suggestions_task)} do
      {{:ok, versions}, suggestions} ->
        {:noreply,
         assign(socket,
           versions: versions,
           version: hd(versions),
           package: package,
           suggestions: suggestions
         )}

      _ ->
        {:noreply, assign(socket, versions: [], package: nil, suggestions: [])}
    end
  end

  @impl true
  def handle_event("select_package", %{"package" => package}, socket) do
    case get_versions(package) do
      {:ok, versions} ->
        {:noreply, assign(socket, package: package, versions: versions, version: hd(versions))}

      _ ->
        {:noreply, assign(socket, package: nil, versions: nil, version: nil)}
    end
  end

  @impl true
  def handle_event("select_version", %{"v" => version}, socket) do
    {:noreply, assign(socket, version: version)}
  end

  @impl true
  def handle_event("select", _params, %{assigns: %{package: package, version: version}} = socket) do
    {:noreply, push_redirect(socket, to: "/source/#{package}/#{version}")}
  end

  defp get_suggestions(query) do
    with {:ok, packages} <- Registry.Npm.search(query) do
      Enum.each(packages, fn package ->
        Packages.create_package(%{name: package, registry: "npm"}, on_conflict: :nothing)
      end)

      packages
      |> Enum.filter(fn package -> package != query end)
      |> Enum.slice(0, 3)
    end
  end

  defp get_versions(package) do
    Registry.Npm.versions(package)
  end
end
