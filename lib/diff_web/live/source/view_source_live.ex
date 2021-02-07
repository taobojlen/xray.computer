defmodule DiffWeb.ViewSourceLive do
  use DiffWeb, :live_view
  alias Diff.Packages.{Package, Version}
  alias Diff.{Packages, Registry, Repo}

  @impl true
  def mount(%{"package" => package, "version" => version}, _session, socket) do
    registry = "npm"

    package = Repo.get_by(Package, registry: registry, name: package)

    version =
      if is_nil(package) do
        nil
      else
        Repo.get_by(Version, package_id: package.id, version: version)
      end

    cond do
      is_nil(package) ->
        # attempt to get the package and version
        mount_loading_state(socket, registry)

      is_nil(version) ->
        # attempt to get the version
        mount_loading_state(socket, registry)

      is_nil(version.source_uri) ->
        # attempt to get the source code
        mount_loading_state(socket, registry)

      true ->
        # we have everything; render it
        # TODO: create Source context to handle this
        source = File.read!(version.source_path)
        {:ok, assign(socket, registry: registry, loading: false, source: source)}
    end
  end

  @impl true
  def handle_info({Packages, [:versions, :created], version}, socket) do
    {:noreply, assign(socket, loading: false, source: version.source_uri)}
  end

  @impl true
  def handle_info({Packages, [:versions, :does_not_exist]}, socket) do
    {:noreply, assign(socket, loading: false, does_not_exist: true)}
  end

  defp mount_loading_state(socket, registry) do
    {:ok, assign(socket, registry: registry, loading: true)}
  end
end
