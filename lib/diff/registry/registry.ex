defmodule Diff.Registry do
  alias Diff.Packages.{Package, Version}
  alias Diff.Registry.Npm

  @behaviour Diff.Registry.Behaviour

  @registries %{
    :npm => Npm
  }

  defmodule API do
    @moduledoc """
    A specification for package registries. Each registry should implement the functions
    described here.
    """
    @type package :: String.t()
    @type version :: String.t()
    @doc """
    Query the registry for the given search term. Returns a list of package names that match.

    Implementations can return just the top *n* results and not worry about pagination.
    """
    @callback search(String.t()) :: {:ok, [package]} | {:error, String.t()}

    @doc """
    Fetch details about the package and return a changeset ready to store in the database.
    Note: the changeset should include associated versions!
    """
    @callback get_package(package) :: {:ok, Package.t()} | {:error, String.t()}

    @doc """
    Given a package name, return a list of versions for that package.
    (Sorted by highest version to lowest).
    """
    @callback get_versions(package) :: {:ok, [Version.t()]} | {:error, String.t()}

    @doc """
    Download the source code for a given package and version.
    Returns the (temporary) path at which it was saved.
    """
    @callback get_source(package, version) :: {:ok, String.t()} | {:error, String.t()}
  end

  @impl true
  def search(registry, query) do
    impl = get_registry(registry)
    impl.search(query)
  end

  @impl true
  def get_package(registry, package) do
    impl = get_registry(registry)
    impl.get_package(package)
  end

  @impl true
  def get_versions(registry, package) do
    impl = get_registry(registry)
    impl.get_versions(package)
  end

  @impl true
  def get_source(registry, package, version) do
    impl = get_registry(registry)
    impl.get_source(package, version)
  end

  defp get_registry(registry) do
    Map.get(@registries, registry)
  end
end
