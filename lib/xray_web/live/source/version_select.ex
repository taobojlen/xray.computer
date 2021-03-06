defmodule XrayWeb.VersionSelect do
  alias Xray.VersionListFetcher
  use XrayWeb, :live_view

  @impl true
  def mount(_params, %{"package" => nil}, socket) do
    {:ok, assign(socket, loading: false, versions: [], version: nil)}
  end

  @impl true
  def mount(_params, %{"registry" => registry, "package" => package}, socket) do
    VersionListFetcher.subscribe(registry, package)
    VersionListFetcher.get_versions(registry, package)

    socket =
      socket
      |> assign(registry: registry)
      |> assign(package: package)
      |> assign(loading: true)
      |> assign(versions: [])
      |> assign(version: nil)

    {:ok, socket}
  end

  @impl true
  def handle_event("select_version", %{"v" => version}, socket) do
    {:noreply, assign(socket, version: version)}
  end

  @impl true
  def handle_event("select", _params, %{assigns: %{package: package, version: version}} = socket) do
    # Scoped packages may contain slashes. To avoid breaking our routes, replace them with something
    # else
    package = package |> String.replace("/", " ") |> URI.encode()
    version = URI.encode(version)
    {:noreply, push_redirect(socket, to: "/source/#{package}/#{version}")}
  end

  @impl true
  def handle_info({VersionListFetcher, :got_versions, versions}, socket) do
    version =
      case versions do
        [] -> nil
        list -> hd(list)
      end

    {:noreply, assign(socket, loading: false, versions: versions, version: version)}
  end
end
