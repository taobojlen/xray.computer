defmodule Xray.Api.NpmTest do
  use ExUnit.Case, async: true
  alias Xray.Api.Npm
  import Hammox

  describe "get" do
    test "caches responses" do
      mock_response = %HTTPoison.Response{
        body: "{ \"key\": \"value\" }",
        request: %HTTPoison.Request{url: "http://localhost"},
        status_code: 200
      }

      # Will error if called more than once
      MockHTTPoison
      |> expect(:get, fn _url ->
        {:ok, mock_response}
      end)

      Npm.get("test.json")
      Npm.get("test.json")

      assert Cachex.get!(:api_cache, "https://registry.npmjs.com/test.json") == mock_response
    end
  end
end
