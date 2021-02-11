defmodule DiffWeb.ViewSourceLive do
  use DiffWeb, :live_view
  # alias Diff.Packages.{Package, Version}
  alias Diff.{Source, Storage}

  @impl true
  def mount(%{"package" => package, "version" => version} = params, _session, socket) do
    registry = "npm"
    Source.subscribe(registry, package, version)
    Source.get_source(registry, package, version)

    filename =
      if params["filename"] do
        URI.decode(params["filename"])
      else
        nil
      end

    {:ok,
     assign(
       socket,
       registry: registry,
       package: package,
       version: version,
       loading: true,
       nonexistent: false,
       files: %{},
       files_list: [],
       current_file: filename,
       lines: nil,
       file_type: nil
     )}
  end

  @impl true
  def handle_event(
        "select_file",
        %{"f" => filename},
        %{assigns: %{package: package, version: version, files: files}} = socket
      ) do
    content =
      files
      |> Map.get(filename)
      |> maybe_get_file_content()

    socket =
      assign(
        socket,
        lines: content,
        current_file: filename,
        file_type: get_file_extension(filename)
      )

    {:noreply,
     push_patch(socket,
       to: Routes.view_source_path(socket, :index, package, version, filename),
       replace: true
     )}
  end

  @impl true
  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info(
        {Source, :not_found, _content},
        %{assigns: %{registry: registry, package: package, version: version}} = socket
      ) do
    Source.unsubscribe(registry, package, version)
    {:noreply, assign(socket, loading: false, nonexistent: true)}
  end

  @impl true
  def handle_info(
        {Source, :found_source, files_list_key},
        %{assigns: %{current_file: filename}} = socket
      ) do
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

    {:noreply,
     assign(socket,
       files: files,
       files_list: files_list,
       current_file: filename,
       lines: content,
       file_type: file_type,
       loading: false
     )}
  end

  defp get_file_extension(filename) do
    String.split(filename, ".")
    |> List.last()
  end

  defp maybe_get_file_content(key) do
    content = Storage.get(key)

    if String.valid?(content) do
      String.split(content, "\n")
    else
      "Cannot display binary file"
    end
  end
end
