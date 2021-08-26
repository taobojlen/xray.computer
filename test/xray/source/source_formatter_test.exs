defmodule Xray.Source.SourceFormatterTest do
  use Xray.DataCase
  use Oban.Testing, repo: Xray.Repo
  import Mox
  alias Xray.Source

  describe "perform" do
    test "formats source code" do
      file_key = "/a/b/c.js"

      Xray.Storage.MockS3
      |> expect(:get_to_filesystem, fn ^file_key, path ->
        File.mkdir_p!(Path.dirname(path))
        File.write!(path, "const a = 123")
        :ok
      end)
      |> expect(:put_from_filesystem, fn "formatted/a/b/c.js", _path ->
        :ok
      end)

      package = insert(:package)
      version = insert(:version, package: package)
      version_id = version.id
      expected_formatted_source = "const a = 123;\n"
      Source.FormattedSource.subscribe(version_id, file_key)

      assert :ok =
               perform_job(Source.SourceFormatter, %{"id" => version.id, "file_key" => file_key})

      assert_receive {Source.FormattedSource, ^version_id, ^file_key, ^expected_formatted_source}
    end
  end
end
