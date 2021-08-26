defmodule Xray.Registry do
  alias Xray.Repo
  alias Xray.Packages.{Package, Version}
  alias Xray.Registry.Npm
  import Ecto.Query

  @behaviour __MODULE__.Contract

  @registries %{
    "npm" => Npm
  }

  @impl true
  def get_registries do
    Map.keys(@registries)
  end

  @impl true
  def is_registry("npm"), do: true
  @impl true
  def is_registry(_other), do: false

  @impl true
  def search(registry, query) do
    Repo.all(
      from p in Package,
        select: p.name,
        where: ilike(p.name, ^"%#{query}%"),
        where: p.registry == ^registry,
        limit: 3
    )
  end

  @impl true
  def get_packages!(registry) do
    impl = get_registry(registry)
    impl.get_packages!()
  end

  @impl true
  def get_package(registry, package) do
    impl = get_registry(registry)
    impl.get_package(package)
  end

  @impl true
  def get_versions(registry, package) do
    impl = get_registry(registry)
    # TODO: update last_updated for package
    if package == "" do
      []
    else
      impl.get_versions(package)
    end
  end

  @impl true
  def get_source(registry, package, version) do
    impl = get_registry(registry)
    impl.get_source(package, version)
  end

  @impl true
  def format(registry, path) do
    impl = get_registry(registry)
    impl.format(path)
  end

  defp get_registry(registry) do
    Map.get(@registries, registry)
  end

  defmodule Contract do
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
    @callback get_source(registry, package, version) ::
                {:ok, String.t(), String.t()} | {:error, String.t()}
    @callback format(registry, String.t()) :: :ok | {:error, term()}
  end
end
