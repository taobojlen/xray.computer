defmodule DiffWeb.ViewSourceLive do
  use DiffWeb, :live_view
  # alias Diff.Packages.{Package, Version}
  alias Diff.{Source, Storage}

  @file_extensions %{
    ".js" => "javascript",
    ".md" => "markdown",
    ".css" => "css",
    ".sh" => "bash",
    ".ts" => "typescript",
    ".yaml" => "yaml",
    ".yml" => "yaml",
    ".scss" => "scss"
  }

  @impl true
  def mount(%{"package" => package, "version" => version}, _session, socket) do
    registry = "npm"
    Source.subscribe(registry, package, version)
    Source.get_source(registry, package, version)

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
       current_file: nil,
       content: nil,
       file_type: nil
     )}
  end

  @impl true
  def handle_event("select_file", %{"f" => filename}, %{assigns: %{files: files}} = socket) do
    content =
      files
      |> Map.get(filename)
      |> Storage.get()

    file_type = get_file_type(filename)

    {:noreply, assign(socket, content: content, current_file: filename, file_type: file_type)}
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
  def handle_info({Source, :found_source, files_list_key}, socket) do
    files =
      Storage.get(files_list_key)
      |> Jason.decode!()

    files_list =
      files
      |> Enum.map(fn {filename, _key} -> filename end)
      |> Enum.sort()

    content =
      files
      |> Map.get(hd(files_list))
      |> Storage.get()

    file_type = get_file_type(hd(files_list))

    {:noreply,
     assign(socket,
       files: files,
       files_list: files_list,
       current_file: hd(files_list),
       content: content,
       file_type: file_type,
       loading: false
     )}
  end

  defp get_file_type(filename) do
    potentials =
      @file_extensions
      |> Enum.filter(fn {extension, language} ->
        String.ends_with?(filename, extension)
      end)
      |> Enum.map(fn {_extension, language} -> language end)

    if length(potentials) > 0 do
      hd(potentials)
    else
      nil
    end
  end
end
