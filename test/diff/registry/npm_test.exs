defmodule Diff.Registry.NpmTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  alias Diff.Packages.Version
  alias Diff.Registry.Npm

  setup_all do
    HTTPoison.start()
  end

  describe "get_packages" do
    test "it gets the full list of packages" do
      use_cassette "npm" do
        with {:ok, packages} <- Npm.get_packages() do
          package_set = MapSet.new(packages)

          assert length(packages) == 1
          assert MapSet.size(package_set) == 1
        end
      end
    end
  end

  describe "get_versions" do
    test "it handles existing versions" do
      use_cassette "npm" do
        with {:ok, versions} <- Npm.get_versions("lodash") do
          latest = hd(versions)

          assert latest.version == "4.17.20"
          assert length(versions) == 113

          versions
          |> Enum.each(fn version ->
            changeset = Version.changeset(version, %{})
            assert changeset.valid?
          end)
        end
      end
    end
  end

  describe "get_package" do
    test "it handles existing packages" do
      use_cassette "npm" do
        with {:ok, changeset} <- Npm.get_package("lodash") do
          assert changeset.valid?
        end
      end
    end
  end
end
