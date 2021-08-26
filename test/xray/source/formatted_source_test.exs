defmodule Xray.Source.FormattedSourceTest do
  use Xray.DataCase
  use Oban.Testing, repo: Xray.Repo
  import Mox
  alias Xray.Source.{FormattedSource, SourceFormatter}

  describe "get_formatted_file" do
    test "finds an already-formatted file" do
      version_id = 123
      file_key = "/a/b/c.js"
      formatted_key = "formatted#{file_key}"
      formatted_source = "const a = 123;\n"
      FormattedSource.subscribe(version_id, file_key)

      Xray.Storage.MockS3
      |> expect(:get, fn ^formatted_key ->
        formatted_source
      end)

      FormattedSource.get_formatted_file(version_id, file_key)

      assert_receive {FormattedSource, ^version_id, ^file_key, ^formatted_source}
    end

    test "starts an async job if the file is not already formatted" do
      version_id = 123
      file_key = "/a/b/c.js"
      formatted_key = "formatted#{file_key}"
      FormattedSource.subscribe(version_id, file_key)

      Xray.Storage.MockS3
      |> expect(:get, fn ^formatted_key ->
        nil
      end)

      FormattedSource.get_formatted_file(version_id, file_key)

      assert_enqueued(worker: SourceFormatter, args: %{id: version_id, file_key: file_key})
    end
  end
end
