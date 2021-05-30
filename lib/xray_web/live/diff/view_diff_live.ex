defmodule XrayWeb.ViewDiffLive do
  use Surface.LiveView
  alias Surface.Components.LiveRedirect
  alias XrayWeb.Components.{DiffPatch, MainPage, SourceLoadingBar}
  alias XrayWeb.Endpoint
  alias XrayWeb.Router.Helpers

  alias Xray.Diff
  alias Xray.Diff.DiffServer
  alias Xray.Storage

  data page_title, :string
  data registry, :string
  data package, :string
  data version_from, :string
  data version_to, :string
  data loading, :boolean, default: true
  data loading_status, :string, default: nil
  data progress, :decimal, default: 1
  data diff, :any

  @impl true
  def mount(
        %{
          "registry" => registry,
          "package" => package,
          "version_from" => version_from,
          "version_to" => version_to
        },
        _session,
        socket
      ) do
    package = URI.decode(package) |> String.replace(" ", "/")
    version_from = URI.decode(version_from)
    version_to = URI.decode(version_to)

    DiffServer.subscribe(registry, package, version_from, version_to)
    Task.start_link(fn -> DiffServer.get_diff(registry, package, version_from, version_to) end)

    socket =
      socket
      |> assign(registry: registry)
      |> assign(package: package)
      |> assign(version_from: version_from)
      |> assign(version_to: version_to)
      |> assign(page_title: "#{package} #{version_from} to #{version_to}")

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <MainPage
      page="diff"
      title={{ @page_title }}
      wide={{ true }}
    >
      <template slot="custom_title">
        {{ @package }}
        <LiveRedirect to={{ Helpers.view_source_path(Endpoint, :index, @registry, @package, @version_from) }}>
          {{ @version_from }}
        </LiveRedirect>
        <i class="fas fa-long-arrow-alt-right mx-1" />
        <LiveRedirect to={{ Helpers.view_source_path(Endpoint, :index, @registry, @package, @version_to) }}>
          {{ @version_to }}
        </LiveRedirect>
      </template>
      <template>
        <div :if={{ @loading }} class="mt-10">
          <SourceLoadingBar
            registry={{ @registry }}
            progress={{ @progress }}
            status_text={{ @loading_status }}
          />
        </div>
        <div :if={{ not @loading }} class="space-y-4 w-full">
          <DiffPatch :for={{ patch <- @diff }} patch={{ patch }} />
        </div>
      </template>
    </MainPage>
    """
  end

  @impl true
  def handle_info(
        {DiffServer, :error, error},
        %{
          assigns: %{
            registry: registry,
            package: package,
            version_from: version_from,
            version_to: version_to
          }
        } = socket
      ) do
    DiffServer.unsubscribe(registry, package, version_from, version_to)
    {:noreply, assign(socket, loading: false, error: error)}
  end

  @impl true
  def handle_info(
        {DiffServer, :progress, progress},
        socket
      ) do
    {:noreply, assign(socket, progress: progress)}
  end

  @impl true
  def handle_info(
        {DiffServer, :found_source, _version_id},
        socket
      ) do
    {:noreply, assign(socket, loading_status: "Calculating diff...", progress: 1)}
  end

  @impl true
  def handle_info(
        {DiffServer, :got_diff, diff_key},
        %{
          assigns: %{
            registry: registry,
            package: package,
            version_from: version_from,
            version_to: version_to
          }
        } = socket
      ) do
    raw_diff = Storage.get(diff_key)
    diff_record = Diff.get_diff(registry, package, version_from, version_to)

    case GitDiff.parse_patch(raw_diff,
           relative_from: diff_record.from_path,
           relative_to: diff_record.to_path
         ) do
      {:ok, diff} ->
        {:noreply, assign(socket, loading: false, diff: diff)}

      _ ->
        {:noreply, assign(socket, loading: false, error: "Failed to parse git diff")}
    end
  end
end
