defmodule Xray.UtilTest do
  use ExUnit.Case

  alias Xray.Util

  describe "sort_versions/1" do
    test "sorts a list of versions" do
      versions = [
        "1.0.0-rc.1",
        "4.9.0",
        "0.9.1",
        "4.17.15"
      ]

      expected = [
        "4.17.15",
        "4.9.0",
        "1.0.0-rc.1",
        "0.9.1"
      ]

      assert Util.sort_versions(versions) == expected
    end

    test "handles non-SemVer strings" do
      versions = [
        "1.0.0",
        "abc",
        "1.2.3"
      ]

      expected = [
        "1.2.3",
        "abc",
        "1.0.0"
      ]

      assert Util.sort_versions(versions) == expected
    end
  end
end
