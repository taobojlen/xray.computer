defmodule Xray.Registry.Behaviour do
  alias Xray.Packages.{Package, Version}

  @moduledoc """
  A specification for an individual package registry. Each registry should implement the functions
  described here.
  """
  @type package :: String.t()
  @type version :: String.t()

  @doc """
  Fetch a list of all packages in the registry.
  """
  @callback get_packages!() :: [package]

  @doc """
  Fetch details about the package and return a changeset ready to store in the database.
  Note: the changeset should include associated versions!
  """
  @callback get_package(package) :: {:ok, Package.t()} | {:error, String.t()}

  @doc """
  Given a package name, return a list of versions for that package.
  """
  @callback get_versions(package) :: {:ok, [Version.t()]} | {:error, String.t()}

  @doc """
  Download the source code for a given package and version.
  Returns the (temporary) path at which it was saved, and the path of a compressed tarball.
  """
  @callback get_source(package, version) :: {:ok, String.t(), String.t()} | {:error, String.t()}
end
