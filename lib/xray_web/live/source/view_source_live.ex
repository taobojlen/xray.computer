defmodule XrayWeb.ViewSourceLive do
  use Surface.LiveView
  alias XrayWeb.Components.{ErrorCallout, FileSelect, MainPage, SourceCode, SourceLoadingBar}

  alias Xray.{Packages, Source, Storage, Util}
  alias Xray.Source.FormattedSource
  alias XrayWeb.Router.Helpers, as: Routes

  data page_title, :string
  data registry, :string
  data package, :string
  data version, :string
  data version_id, :number
  data loading, :boolean, default: true
  data progress, :decimal, default: 1
  # TODO: show error to user
  data error, :string, default: nil
  data filename, :string, default: nil
  data files, :map, default: %{}
  data current_file, :string, default: nil
  data file_type, :string, default: nil
  data code, :string, default: nil
  data uri_hash, :string, default: nil
  data released_at, :datetime, default: nil
  data viewing_formatted, :boolean, default: false
  data loading_formatted, :boolean, default: false

  @impl true
  def mount(
        %{"registry" => registry, "package" => package, "version" => version} = params,
        _session,
        socket
      ) do
    package = URI.decode(package) |> String.replace(" ", "/")
    version = URI.decode(version)
    Source.subscribe(registry, package, version)
    Task.start_link(fn -> Source.get_source(registry, package, version) end)

    filename =
      if params["filename"] do
        URI.decode(params["filename"])
      else
        nil
      end

    socket =
      socket
      |> assign(registry: registry)
      |> assign(package: package)
      |> assign(version: version)
      |> assign(current_file: filename)
      |> assign(page_title: "#{package} #{version}")
      |> assign_released_at()

    if params["format"] == "true" do
      {:ok, assign(socket, viewing_formatted: true, loading_formatted: true)}
    else
      {:ok, socket}
    end
  end

  @impl true
  def handle_params(_unsigned_params, uri, socket) do
    %{fragment: fragment} = URI.parse(uri)
    {:noreply, assign(socket, uri_hash: fragment)}
  end

  @impl true
  def render(%{released_at: released_at} = assigns) do
    subtitle = if is_nil(released_at), do: nil, else: "Released " <> released_at

    ~F"""
    <MainPage
      page="source"
      title={@page_title}
      subtitle={subtitle}
      wide={true}
    >
      <div :if={@loading} class="mt-10">
        <SourceLoadingBar
          registry={@registry}
          progress={@progress}
        />
      </div>
      <div
        :if={not @loading}
      >
        <FileSelect
          files={Map.keys(@files)}
          current_file={@current_file}
          viewing_formatted={@viewing_formatted}
          loading_formatted={@loading_formatted}
          select_file="select_file"
          toggle_formatted="toggle_formatted"
        />
        <div :if={@error != nil} class="mx-auto max-w-4xl my-4">
          <ErrorCallout text={@error} />
        </div>
        <SourceCode
          code={@code}
          file_type={@file_type}
          loading_formatted={@loading_formatted}
        />
      </div>
    </MainPage>
    """
  end

  @impl true
  def handle_event(
        "select_file",
        %{"file" => filename},
        socket
      ) do
    select_file(filename, socket)
  end

  @impl true
  def handle_event(
        "toggle_formatted",
        %{"formatted" => "true"},
        socket
      ) do
    fetch_formatted(socket)
  end

  @impl true
  def handle_event(
        "toggle_formatted",
        %{"_target" => _target},
        %{assigns: %{current_file: filename}} = socket
      ) do
    select_file(filename, socket)
  end

  @impl true
  def handle_info(
        {Source, _version, :not_found, _content},
        %{assigns: %{registry: registry, package: package, version: version}} = socket
      ) do
    Source.unsubscribe(registry, package, version)
    {:noreply, assign(socket, loading: false, error: "Not found")}
  end

  @impl true
  def handle_info(
        {Source, _version, :error, error},
        %{assigns: %{registry: registry, package: package, version: version}} = socket
      ) do
    Source.unsubscribe(registry, package, version)
    {:noreply, assign(socket, loading: false, error: error)}
  end

  @impl true
  def handle_info({Source, _version, :progress, progress}, socket) do
    {:noreply, assign(socket, progress: progress)}
  end

  @impl true
  def handle_info(
        {Source, _version, :found_source, version_id},
        %{
          assigns: %{
            current_file: filename,
            registry: registry,
            package: package,
            version: version,
            uri_hash: uri_hash,
            loading_formatted: loading_formatted
          }
        } = socket
      ) do
    files_list_key = Packages.get_version!(version_id).source_key

    # TODO: fetch this just once initially
    files =
      Storage.get(files_list_key)
      |> Jason.decode!()

    files_list =
      files
      |> Enum.map(fn {filename, _key} -> filename end)
      |> Enum.sort()

    filename =
      if filename do
        filename
      else
        hd(files_list)
      end

    content =
      files
      |> Map.get(filename)
      |> maybe_get_file_content()

    file_type = get_file_extension(filename)

    socket =
      socket
      |> assign(files: files)
      |> assign(files_list: files_list)
      |> assign(current_file: filename)
      |> assign(code: content)
      |> assign(file_type: file_type)
      |> assign(loading: false)
      |> assign(version_id: version_id)
      |> assign_released_at()

    destination = Routes.view_source_path(socket, :index, registry, package, version, filename)

    destination =
      if is_nil(uri_hash) do
        destination
      else
        "#{destination}##{uri_hash}"
      end

    # If loading_formatted, it means that this was the initial visit to a URL with
    # ?format=true. Now that we have the files list, etc., we can format the code
    if loading_formatted do
      fetch_formatted(socket)
    else
      {:noreply,
       push_patch(socket,
         to: destination,
         replace: true
       )}
    end
  end

  @impl true
  def handle_info(
        {FormattedSource, _version_id, _file_key, :error},
        %{
          assigns: %{
            registry: registry,
            package: package,
            version: version,
            current_file: filename
          }
        } = socket
      ) do
    socket =
      socket
      |> assign(error: "Could not format file.")
      |> assign(loading_formatted: false)
      |> assign(viewing_formatted: false)

    {:noreply,
     push_patch(socket,
       to: Routes.view_source_path(socket, :index, registry, package, version, filename),
       replace: true
     )}
  end

  @impl true
  def handle_info(
        {FormattedSource, _version_id, _file_key, formatted_source},
        socket
      ) do
    {:noreply, assign(socket, code: formatted_source, loading_formatted: false)}
  end

  defp select_file(
         filename,
         %{assigns: %{registry: registry, package: package, version: version, files: files}} =
           socket
       ) do
    content =
      files
      |> Map.get(filename)
      |> maybe_get_file_content()

    socket =
      assign(
        socket,
        code: content,
        current_file: filename,
        file_type: get_file_extension(filename),
        viewing_formatted: false,
        error: nil
      )

    {:noreply,
     push_patch(socket,
       to: Routes.view_source_path(socket, :index, registry, package, version, filename),
       replace: true
     )}
  end

  defp fetch_formatted(
         %{
           assigns: %{
             registry: registry,
             package: package,
             version: version,
             current_file: filename,
             version_id: version_id,
             files: files,
             uri_hash: uri_hash
           }
         } = socket
       ) do
    file_key = Map.get(files, filename)
    FormattedSource.subscribe(version_id, file_key)
    Task.start_link(fn -> FormattedSource.get_formatted_file(version_id, file_key) end)

    socket =
      socket
      |> assign(loading_formatted: true)
      |> assign(viewing_formatted: true)

    destination =
      Routes.view_source_path(socket, :index, registry, package, version, filename, format: true)

    destination =
      if is_nil(uri_hash) do
        destination
      else
        "#{destination}##{uri_hash}"
      end

    {:noreply,
     push_patch(socket,
       to: destination,
       replace: true
     )}
  end

  defp get_file_extension(filename) do
    String.split(filename, ".")
    |> List.last()
  end

  defp maybe_get_file_content(key) do
    content = Storage.get(key)

    cond do
      byte_size(content) > 1_000_000 ->
        "Cannot display files larger than 1MB"

      not String.valid?(content) ->
        "Cannot display binary file"

      true ->
        content
    end
  end

  defp assign_released_at(
         %{assigns: %{registry: registry, package: package, version: version}} = socket
       ) do
    version_record = Packages.get_version(registry, package, version)
    released_at = if is_nil(version_record), do: nil, else: version_record.released_at
    assign(socket, released_at: Util.beautify_datetime(released_at))
  end
end
