defmodule Xray.UtilTest do
  use ExUnit.Case

  alias Xray.Util

  describe "util" do
    test "sort_versions/1 sorts a list of versions" do
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

    test "sort_versions/1 handles non-SemVer strings" do
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
