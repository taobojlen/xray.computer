defmodule XrayWeb.VersionController do
  use XrayWeb, :controller

  alias Xray.Packages
  alias Xray.Packages.Version

  def index(conn, _params) do
    versions = Packages.list_versions()
    render(conn, "index.html", versions: versions)
  end

  def new(conn, _params) do
    changeset = Packages.change_version(%Version{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"version" => version_params}) do
    case Packages.create_version(version_params) do
      {:ok, version} ->
        conn
        |> put_flash(:info, "Version created successfully.")
        |> redirect(to: Routes.version_path(conn, :show, version))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    version = Packages.get_version!(id)
    render(conn, "show.html", version: version)
  end

  def edit(conn, %{"id" => id}) do
    version = Packages.get_version!(id)
    changeset = Packages.change_version(version)
    render(conn, "edit.html", version: version, changeset: changeset)
  end

  def update(conn, %{"id" => id, "version" => version_params}) do
    version = Packages.get_version!(id)

    case Packages.update_version(version, version_params) do
      {:ok, version} ->
        conn
        |> put_flash(:info, "Version updated successfully.")
        |> redirect(to: Routes.version_path(conn, :show, version))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", version: version, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    version = Packages.get_version!(id)
    {:ok, _version} = Packages.delete_version(version)

    conn
    |> put_flash(:info, "Version deleted successfully.")
    |> redirect(to: Routes.version_path(conn, :index))
  end
end
