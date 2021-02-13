defmodule XrayWeb.PackageController do
  use XrayWeb, :controller

  alias Xray.Packages
  alias Xray.Packages.Package

  def index(conn, _params) do
    packages = Packages.list_packages()
    render(conn, "index.html", packages: packages)
  end

  def new(conn, _params) do
    changeset = Packages.change_package(%Package{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"package" => package_params}) do
    case Packages.create_package(package_params) do
      {:ok, package} ->
        conn
        |> put_flash(:info, "Package created successfully.")
        |> redirect(to: Routes.package_path(conn, :show, package))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    package = Packages.get_package!(id)
    render(conn, "show.html", package: package)
  end

  def edit(conn, %{"id" => id}) do
    package = Packages.get_package!(id)
    changeset = Packages.change_package(package)
    render(conn, "edit.html", package: package, changeset: changeset)
  end

  def update(conn, %{"id" => id, "package" => package_params}) do
    package = Packages.get_package!(id)

    case Packages.update_package(package, package_params) do
      {:ok, package} ->
        conn
        |> put_flash(:info, "Package updated successfully.")
        |> redirect(to: Routes.package_path(conn, :show, package))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", package: package, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    package = Packages.get_package!(id)
    {:ok, _package} = Packages.delete_package(package)

    conn
    |> put_flash(:info, "Package deleted successfully.")
    |> redirect(to: Routes.package_path(conn, :index))
  end
end
