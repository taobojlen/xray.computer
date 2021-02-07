defmodule Diff.Registry.Behaviour do
  @moduledoc """
  A behaviour to interface with package registries.
  In production code, this behaviour is always implemented by Diff.Registry, but in tests
  we might use a mock instead.
  """
  alias Diff.Packages.{Package, Version}

  @type registry :: String.t()
  @type package :: String.t()
  @type version :: String.t()

  @callback search(registry, String.t()) :: {:ok, [package]} | {:error, String.t()}
  @callback get_package(registry, package) :: {:ok, Package.t()} | {:error, String.t()}
  @callback get_versions(registry, package) :: {:ok, [Version.t()]} | {:error, String.t()}
  @callback get_source(registry, package, version) :: {:ok, String.t()} | {:error, String.t()}
end
