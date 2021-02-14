defmodule Xray.Source.SourceFetcherTest do
  use Xray.DataCase
  use Oban.Testing, repo: Xray.Repo
  import Xray.Factory
  import Mox
  alias Xray.Source

  describe "perform" do
    test "fetches source code" do
      # SourceFetcher will delete the temporary path once
      # data has been put into Xray.Storage, so we copy
      # our test data to a temporary location first
      source = Path.absname("test/data/package")
      destination = Path.join(System.tmp_dir!(), "package")
      File.cp_r!(source, destination)

      Xray.MockRegistry
      |> expect(:get_source, fn _registry, _package, _version ->
        {:ok, destination}
      end)

      package = insert(:package)
      version = insert(:version, package: package)

      assert :ok = perform_job(Source.SourceFetcher, %{"id" => version.id})
    end
  end
end
