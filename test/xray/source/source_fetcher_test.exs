defmodule Xray.Source.SourceFetcherTest do
  use Xray.DataCase
  use Oban.Testing, repo: Xray.Repo
  import Xray.Factory
  import Hammox
  alias Xray.Source

  describe "perform" do
    test "fetches source code" do
      # SourceFetcher will delete the temporary path once
      # data has been put into Xray.Storage, so we copy
      # our test data to a temporary location first
      source = Path.absname("test/data/package")
      destination = Path.join(System.tmp_dir!(), "package")
      tarball_path = Path.join(System.tmp_dir!(), "tarball")
      File.cp_r!(source, destination)

      Xray.MockRegistry
      |> expect(:get_source, fn _registry, _package, _version ->
        {:ok, destination, tarball_path}
      end)

      Xray.Storage.MockS3
      |> expect(:put_from_filesystem, fn _a, _b ->
        nil
      end)
      |> expect(
        :put,
        4,
        fn _a, _b ->
          nil
        end
      )

      package = insert(:package)
      version = insert(:version, package: package)

      assert :ok = perform_job(Source.SourceFetcher, %{"id" => version.id})
    end
  end
end
