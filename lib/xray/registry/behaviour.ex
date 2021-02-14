defmodule Xray.Registry.Behaviour do
  @moduledoc """
  A behaviour to interface with package registries.
  In production code, this behaviour is always implemented by Xray.Registry, but in tests
  we might use a mock instead.
  """
  alias Xray.Packages.{Package, Version}

  @type registry :: String.t()
  @type package :: String.t()
  @type version :: String.t()

  @callback get_registries() :: [registry]
  @callback is_registry(String.t()) :: boolean()
  @callback search(registry, String.t()) :: [package]
  @callback get_packages!(registry) :: [package]
  @callback get_package(registry, package) :: {:ok, Package.t()} | {:error, String.t()}
  @callback get_versions(registry, package) :: {:ok, [Version.t()]} | {:error, String.t()}
  @callback get_source(registry, package, version) :: {:ok, String.t()} | {:error, String.t()}
end
