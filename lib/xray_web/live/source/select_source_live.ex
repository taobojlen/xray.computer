defmodule XrayWeb.SelectSourceLive do
  use Surface.LiveView
  alias Surface.Components.LiveRedirect

  alias Xray.{Util, VersionListFetcher}
  alias XrayWeb.Endpoint
  alias XrayWeb.Router.Helpers
  alias XrayWeb.Components.{MainPage, PackageSearchField, VersionSelect}

  data registry, :string, default: "npm"
  data package, :string, default: nil
  data loading_versions, :boolean, default: false
  data versions, :list, default: []
  data version, :string, default: nil

  @impl true
  def render(%{registry: registry, package: package, version: version} = assigns) do
    source_url =
      if not is_nil(package) and not is_nil(version) do
        Helpers.view_source_path(Endpoint, :index, registry, package, version)
      else
        nil
      end

    ~H"""
    <MainPage title="View source" page="source" description="Read the published source code of any npm package.">
      <div class="flex flex-col items-center">
        <PackageSearchField
          id="package-search"
          package={{ @package }}
          registry={{ @registry }}
        />
        <VersionSelect
          :if={{ not is_nil(@package) }}
          version={{ @version }}
          versions={{ @versions }}
          loading={{ @loading_versions }}
          select_version="select_version"
        />
        <LiveRedirect
          :if={{ not is_nil(@package) and not is_nil(@version) }}
          to={{ source_url }}
          class="button mt-4"
        >
          <button>View source</button>
        </LiveRedirect>
      </div>
    </MainPage>
    """
  end

  @doc """
  Handle the selected package from the PackageSearchField
  """
  @impl true
  def handle_info({:select_package, package}, %{assigns: %{registry: registry}} = socket) do
    VersionListFetcher.subscribe(registry, package)
    Task.start_link(fn -> VersionListFetcher.get_versions(registry, package) end)

    socket =
      socket
      |> assign(package: package)
      |> assign(loading_versions: true)
      |> assign(version: nil)
      |> assign(versions: [])

    {:noreply, socket}
  end

  @impl true
  def handle_info({VersionListFetcher, :got_versions, versions}, socket) do
    versions = Util.sort_versions(versions)

    version =
      case versions do
        [] -> nil
        list -> hd(list)
      end

    socket =
      socket
      |> assign(loading_versions: false)
      |> assign(version: version)
      |> assign(versions: versions)

    {:noreply, socket}
  end

  @impl true
  def handle_event("select_version", %{"version" => version}, socket) do
    {:noreply, assign(socket, version: version)}
  end
end
