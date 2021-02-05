defmodule DiffWeb.ViewSourceLive do
  use DiffWeb, :live_view
  import Ecto.Query
  alias Diff.{Packages, Registry, Repo}
  alias Diff.Packages.{Package, Version}

  @impl true
  def mount(%{"package" => package, "version" => version}, _session, socket) do
    package = Package.get_by(registry: "npm", name: package)
    version = Version.get_by(package: package, version: version)

    cond do
      is_nil(package) ->
        mount_loading_state(socket)
        fetch_package("npm", package)
    end

    if connected?(socket), do: Packages.subscribe(package, version)

    {:ok, assign(socket, loading: true, registry: "npm")}
  end

  @impl true
  def handle_info({Packages, [:versions, :created], version}, socket) do
    {:noreply, assign(socket, loading: false, source: version.source_path)}
  end

  defp mount_loading_state(socket) do
    {:ok, assign(socket, loading: true, registry: "npm")}
  end

  defp fetch_package(registry, package) do
    case Registry.Npm.versions(package) do
      {:ok, versions} ->
        Packages.create_package(%{registry: registry, name: package})
    end
  end

  defp fetch_source_code(version) do
    with {:ok, path} <- Diff.Registry.Npm.get_package(version.package, version.version) do
      IO.puts(path)
      Packages.update_version(version, %{source_path: path})
    end
  end
end
