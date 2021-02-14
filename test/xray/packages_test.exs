defmodule Xray.PackagesTest do
  use Xray.DataCase

  alias Xray.Packages

  describe "packages" do
    alias Xray.Packages.Package

    @valid_attrs %{
      name: "some name",
      registry: "some registry",
      versions_updated_at: "2010-04-17T14:00:00Z"
    }
    @update_attrs %{
      name: "some updated name",
      registry: "some updated registry",
      versions_updated_at: "2011-05-18T15:01:01Z"
    }
    @invalid_attrs %{name: nil, registry: nil, versions_updated_at: nil}

    def package_fixture(attrs \\ %{}) do
      {:ok, package} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Packages.create_package()

      package
    end

    test "list_packages/0 returns all packages" do
      package = package_fixture()
      assert Packages.list_packages() == [package]
    end

    test "get_package!/1 returns the package with given id" do
      package = package_fixture()
      assert Packages.get_package!(package.id) == package
    end

    test "create_package/1 with valid data creates a package" do
      assert {:ok, %Package{} = package} = Packages.create_package(@valid_attrs)
      assert package.name == "some name"
      assert package.registry == "some registry"

      assert package.versions_updated_at ==
               DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
    end

    test "create_package/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Packages.create_package(@invalid_attrs)
    end

    test "update_package/2 with valid data updates the package" do
      package = package_fixture()
      assert {:ok, %Package{} = package} = Packages.update_package(package, @update_attrs)
      assert package.name == "some updated name"
      assert package.registry == "some updated registry"

      assert package.versions_updated_at ==
               DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
    end

    test "update_package/2 with invalid data returns error changeset" do
      package = package_fixture()
      assert {:error, %Ecto.Changeset{}} = Packages.update_package(package, @invalid_attrs)
      assert package == Packages.get_package!(package.id)
    end

    test "delete_package/1 deletes the package" do
      package = package_fixture()
      assert {:ok, %Package{}} = Packages.delete_package(package)
      assert_raise Ecto.NoResultsError, fn -> Packages.get_package!(package.id) end
    end

    test "change_package/1 returns a package changeset" do
      package = package_fixture()
      assert %Ecto.Changeset{} = Packages.change_package(package)
    end
  end

  describe "versions" do
    alias Xray.Packages.Version

    @valid_attrs %{released_at: "2010-04-17T14:00:00Z", version: "some version"}
    @update_attrs %{released_at: "2011-05-18T15:01:01Z", version: "some updated version"}
    @invalid_attrs %{released_at: nil, version: nil}

    def version_fixture(attrs \\ %{}) do
      {:ok, version} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Packages.create_version()

      version
    end

    test "list_versions/0 returns all versions" do
      version = version_fixture()
      assert Packages.list_versions() == [version]
    end

    test "get_version!/1 returns the version with given id" do
      version = version_fixture()
      assert Packages.get_version!(version.id) == version
    end

    test "create_version/1 with valid data creates a version" do
      assert {:ok, %Version{} = version} = Packages.create_version(@valid_attrs)
      assert version.released_at == DateTime.from_naive!(~N[2010-04-17T14:00:00Z], "Etc/UTC")
      assert version.version == "some version"
    end

    test "create_version/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Packages.create_version(@invalid_attrs)
    end

    test "update_version/2 with valid data updates the version" do
      version = version_fixture()
      assert {:ok, %Version{} = version} = Packages.update_version(version, @update_attrs)
      assert version.released_at == DateTime.from_naive!(~N[2011-05-18T15:01:01Z], "Etc/UTC")
      assert version.version == "some updated version"
    end

    test "update_version/2 with invalid data returns error changeset" do
      version = version_fixture()
      assert {:error, %Ecto.Changeset{}} = Packages.update_version(version, @invalid_attrs)
      assert version == Packages.get_version!(version.id)
    end

    test "delete_version/1 deletes the version" do
      version = version_fixture()
      assert {:ok, %Version{}} = Packages.delete_version(version)
      assert_raise Ecto.NoResultsError, fn -> Packages.get_version!(version.id) end
    end

    test "change_version/1 returns a version changeset" do
      version = version_fixture()
      assert %Ecto.Changeset{} = Packages.change_version(version)
    end
  end
end
