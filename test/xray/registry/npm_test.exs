defmodule Xray.Registry.NpmTest do
  use ExUnit.Case, async: true

  alias Xray.{Api, Util}
  alias Xray.Packages.Version
  alias Xray.Registry.Npm

  import Mox

  setup :verify_on_exit!

  describe "get_packages" do
    test "it gets the full list of packages" do
      Api.MockNpm
      |> expect(:get_stream!, fn _ -> File.stream!("test/data/npm/all_docs.json") end)

      with packages <- Npm.get_packages!() do
        package_set = MapSet.new(packages)

        # Assert that packages were read correctly, and that
        # there are no duplicates
        assert length(packages) == 99
        assert MapSet.size(package_set) == 99
      end
    end
  end

  describe "get_versions" do
    test "it handles existing versions" do
      Api.MockNpm
      |> expect(:get, fn _ ->
        {:ok, %{body: File.read!("test/data/npm/lodash.json") |> Jason.decode!()}}
      end)

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

  describe "get_package" do
    test "it handles existing packages" do
      Api.MockNpm
      # called once to get metadata, once to get versions
      |> expect(:get, 2, fn _ ->
        {:ok, %{body: File.read!("test/data/npm/lodash.json") |> Jason.decode!()}}
      end)

      with {:ok, changeset} <- Npm.get_package("lodash") do
        assert changeset.valid?
      end
    end
  end

  describe "format" do
    test "it uses prettier to format" do
      path = Path.join([Util.tmp_path(), "example.js"])
      File.cp!("test/data/npm/example.js", path)
      expected = File.read!("test/data/npm/example.formatted.js")

      with :ok <- Npm.format(path) do
        new_content = File.read!(path)

        assert expected == new_content
      end

      File.rm!(path)
    end
  end
end
