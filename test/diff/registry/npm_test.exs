defmodule Diff.Registry.NpmTest do
  use ExUnit.Case, async: true
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  alias Diff.Registry.Npm

  setup_all do
    HTTPoison.start()
  end

  test "get_package" do
    use_cassette "npm" do
      assert Npm.get_package("lodash")
    end
  end
end
