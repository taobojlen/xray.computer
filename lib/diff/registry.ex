defmodule Diff.Registry do
  @moduledoc """
  A specification for package registries. Each registry should implement the functions
  described here.
  """

  @doc """
  Query the registry for the given search term. Returns a list of package names that match.

  Implementations can return just the top *n* results and not worry about pagination.
  """
  @callback search(String.t()) :: {:ok, [String.t()]} | {:error, String.t()}

  @doc """
  Given a package name, return a list of versions for that package.
  """
  @callback versions(String.t()) :: {:ok, [String.t()]} | {:error, String.t()}
end
