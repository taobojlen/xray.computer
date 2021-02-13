defmodule XrayWeb.SelectSourceLive do
  alias Xray.{Packages, Registry, Repo}
  import Ecto.Query
  use XrayWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, version: nil, versions: [], package: nil, suggestions: [])}
  end

  @impl true
  def handle_event("type", %{"p" => package}, socket) do
    versions_task = Task.async(fn -> get_versions(package) end)
    suggestions_task = Task.async(fn -> get_suggestions(package) end)

    versions = Task.await(versions_task)
    suggestions = Task.await(suggestions_task)

    {:noreply,
     assign(socket,
       versions: versions,
       version: hd(versions),
       package: package,
       suggestions: suggestions
     )}
  end

  @impl true
  def handle_event("select_package", %{"package" => package}, socket) do
    versions = get_versions(package)
    {:noreply, assign(socket, package: package, versions: versions, version: hd(versions))}
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
    case Registry.Npm.get_versions(package) do
      {:ok, versions} ->
        versions
        |> Enum.map(fn %{version: version} ->
          version
        end)

      _other ->
        []
    end
  end
end
