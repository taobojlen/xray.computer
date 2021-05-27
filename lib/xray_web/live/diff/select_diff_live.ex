defmodule XrayWeb.SelectDiffLive do
  use Surface.LiveView
  alias Surface.Components.LiveRedirect
  alias XrayWeb.Components.MainPage

  alias Xray.{Util, VersionListFetcher}
  alias XrayWeb.Endpoint
  alias XrayWeb.Router.Helpers
  alias XrayWeb.Components.{LoadingSpinner, MainPage, PackageSearchField, VersionSelect}

  data registry, :string, default: "npm"
  data package, :string, default: nil
  data loading_versions, :boolean, default: false
  data versions, :list, default: []
  data versions_from, :list, default: []
  data versions_to, :list, default: []
  data version_from, :string, default: nil
  data version_to, :string, default: nil

  @impl true
  def render(
        %{
          registry: registry,
          package: package,
          versions: versions,
          version_from: version_from,
          version_to: version_to
        } = assigns
      ) do
    diff_url =
      if not is_nil(package) and not is_nil(version_from) and not is_nil(version_to) do
        Helpers.view_diff_path(Endpoint, :index, registry, package, version_from, version_to)
      else
        nil
      end

    source_url =
      if not is_nil(package) and not Enum.empty?(versions) do
        Helpers.view_source_path(Endpoint, :index, registry, package, hd(versions))
      else
        nil
      end

    ~H"""
    <MainPage title="Diff" page="diff" description="See what changed between different versions of an npm package.">
      <div class="flex flex-col items-center">
        <PackageSearchField
          id="package-search"
          package={{ @package }}
          registry={{ @registry }}
        />
        <div
          :if={{ not is_nil(@package) }}
        >
          <LoadingSpinner :if={{ @loading_versions }} />
          <div :if={{ not @loading_versions and not Enum.empty?(@versions_from) }}>
            <VersionSelect
              selected_version={{ @version_from }}
              versions={{ @versions_from }}
              select_version="select_version_from"
              label="From"
            />
            <i class="fas fa-arrow-down text-center w-full text-gray-400 mt-4" />
            <VersionSelect
              selected_version={{ @version_to }}
              versions={{ @versions_to }}
              select_version="select_version_to"
              label="To"
            />
          </div>
        </div>
        <LiveRedirect
          :if={{ not is_nil(@version_from) and not is_nil(@version_to) }}
          to={{ diff_url }}
          class="button mt-4"
        >
          View diff
        </LiveRedirect>

        <p :if={{ length(@versions) == 1}} class="mt-4">
        This package only has one version ({{ hd(@versions) }}).
          <LiveRedirect
            :if={{ length(@versions) == 1 }}
            to={{ source_url }}
          >
            View source
          </LiveRedirect>
        </p>
      </div>
    </MainPage>
    """
  end

  @doc """
  Handle the selected package from the PackageSearchField
  """
  @impl true
  def handle_info(
        {:select_package, package},
        %{assigns: %{package: current_package, registry: registry}} = socket
      ) do
    VersionListFetcher.unsubscribe(registry, current_package)
    VersionListFetcher.subscribe(registry, package)
    Task.start_link(fn -> VersionListFetcher.get_versions(registry, package) end)

    socket =
      socket
      |> assign(package: package)
      |> assign(loading_versions: true)
      |> assign(version_from: nil)
      |> assign(version_to: nil)
      |> assign(versions: [])

    {:noreply, socket}
  end

  @impl true
  def handle_info({VersionListFetcher, :got_versions, versions}, socket) do
    versions = Util.sort_versions(versions)

    {version_from, version_to, versions_from, versions_to} =
      case versions do
        [] ->
          {nil, nil, [], []}

        [first, second | _] ->
          [_ | versions_from] = versions
          {second, first, versions_from, [first]}

        [_] ->
          {nil, nil, [], []}
      end

    socket =
      socket
      |> assign(loading_versions: false)
      |> assign(versions: versions)
      |> assign(version_from: version_from)
      |> assign(version_to: version_to)
      |> assign(versions_from: versions_from)
      |> assign(versions_to: versions_to)

    {:noreply, socket}
  end

  @impl true
  def handle_event(
        "select_version_from",
        %{"version" => version},
        %{assigns: %{versions: versions, version_to: version_to}} = socket
      ) do
    # Limit versions_to to later versions
    from_index = Enum.find_index(versions, &(&1 == version))
    versions_to = Enum.slice(versions, 0..(from_index - 1))
    # Ensure that version_to is an element of versions_to
    version_to =
      if Enum.member?(versions_to, version_to) do
        version_to
      else
        Enum.at(versions_to, -1)
      end

    socket =
      socket
      |> assign(version_from: version)
      |> assign(versions_to: versions_to)
      |> assign(version_to: version_to)

    {:noreply, socket}
  end

  @impl true
  def handle_event("select_version_to", %{"version" => version}, socket) do
    {:noreply, assign(socket, version_to: version)}
  end
end
