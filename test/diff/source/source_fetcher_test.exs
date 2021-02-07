defmodule Diff.Source.SourceFetcherTest do
  use Diff.DataCase
  use Oban.Testing, repo: Diff.Repo
  import Diff.Factory
  import Mox
  alias Diff.{Packages, Repo, Source, Storage}

  describe "perform" do
    test "fetches source code" do
      # SourceFetcher will delete the temporary path once
      # data has been put into Diff.Storage, so we copy
      # our test data to a temporary location first
      source = Path.absname("test/data/package")
      destination = Path.join(System.tmp_dir!(), "package")
      File.cp_r!(source, destination)

      Diff.MockRegistry
      |> expect(:get_source, fn _registry, _package, _version ->
        {:ok, destination}
      end)

      package = insert!(:package)
      version = insert!(:version, package_id: package.id)

      assert :ok = perform_job(Source.SourceFetcher, %{"id" => version.id})
    end
  end
end
