defmodule Xray.Registry.PackageListFetcherTest do
  use Xray.DataCase
  use Oban.Testing, repo: Xray.Repo
  import Mox
  alias Xray.{Packages, Registry}

  describe "perform" do
    test "saves list of packages" do
      packages =
        Faker.Util.sample_uniq(10, fn ->
          Faker.App.name() |> String.replace(" ", "-") |> String.downcase()
        end)

      Xray.MockRegistry
      |> expect(:get_packages!, fn _ -> packages end)

      perform_job(Registry.PackageListFetcher, %{"registry" => "npm"})
      actual = Packages.list_packages() |> Enum.map(fn p -> p.name end) |> Enum.sort()
      expected = Enum.sort(packages)

      assert actual == expected
    end
  end
end
