defmodule Xray.Source do
  alias Xray.Repo
  alias Xray.Packages.{Package, Version}
  alias Xray.Source.SourceFetcher

  @type event :: :not_found | :found_source | :progress | :error
  @type event_content :: String.t() | Integer.t() | nil
  @type registry :: String.t()
  @type package :: String.t()
  @type version :: String.t()

  @registry Application.compile_env!(:xray, :registry)
  @topic inspect(__MODULE__)

  @spec get_storage_key(registry, package, version) :: String.t()
  def get_storage_key(registry, package, version) do
    "#{registry}/#{package}/#{version}"
  end

  @spec get_topic(registry, package, version) :: String.t()
  def get_topic(registry, package, version) do
    @topic <> "#{registry}-#{package}-#{version}"
  end

  @spec subscribe(String.t(), String.t(), String.t()) :: :ok | {:error, term}
  def subscribe(registry, package, version) do
    Phoenix.PubSub.subscribe(Xray.PubSub, get_topic(registry, package, version))
  end

  def unsubscribe(registry, package, version) do
    Phoenix.PubSub.unsubscribe(Xray.PubSub, get_topic(registry, package, version))
  end

  @spec notify_found_source(registry, package, version, Integer.t()) :: :ok | {:error, term}
  def notify_found_source(registry, package, version, version_id) do
    notify_subscribers(
      registry,
      package,
      version,
      :found_source,
      version_id
    )
  end

  @spec notify_progress(registry, package, version, Integer.t()) :: :ok | {:error, term}
  def notify_progress(registry, package, version, progress) do
    notify_subscribers(
      registry,
      package,
      version,
      :progress,
      progress
    )
  end

  @spec notify_error(registry, package, version, String.t()) :: :ok | {:error, term}
  def notify_error(registry, package, version, error_message) do
    notify_subscribers(
      registry,
      package,
      version,
      :error,
      error_message
    )
  end

  @doc """
  Gets the source code for the given registry/package/version combo.
  Because this can be fast (if we already have the source) or slow (if we need to download
  it first), results are returned via PubSub.
  Subscribers will receive either a :not_found event, if the registry, package, or version
  does not exist, or a :found_source event once we have the source code.
  """
  @spec get_source(registry, package, version) :: :ok
  def get_source(registry, package, version) do
    if @registry.is_registry(registry) do
      get_package_and_version(registry, package, version)
    else
      notify_subscribers(registry, package, version, :not_found, nil)
    end

    :ok
  end

  @spec get_package_and_version(registry, package, version) :: any()
  defp get_package_and_version(registry, package_name, version_name) do
    with {:ok, package} <- get_package(registry, package_name),
         {:ok, version} <- get_version(registry, package, version_name) do
      if is_nil(version.files) do
        %{id: version.id}
        |> SourceFetcher.new()
        |> Oban.insert()
      else
        notify_found_source(registry, package_name, version_name, version.id)
      end
    else
      {:error, _error} ->
        notify_subscribers(registry, package_name, version_name, :not_found, nil)
    end
  end

  @spec get_package(registry, package) :: {:ok, Package.t()} | {:error, any()}
  defp get_package(registry, package) do
    case Repo.get_by(Package, name: package, registry: registry) do
      nil ->
        with {:ok, changeset} <- @registry.get_package(registry, package),
             {:ok, struct} <- Repo.insert(changeset) do
          {:ok, struct}
        else
          {:error, error} ->
            {:error, error}
        end

      found ->
        {:ok, found}
    end
  end

  @spec get_version(registry, Package.t(), version) :: {:ok, Version.t()} | {:error, any()}
  defp get_version(registry, package, version) do
    case Repo.get_by(Version, package_id: package.id, version: version) do
      nil ->
        get_unknown_version(registry, package, version)

      found ->
        {:ok, found}
    end
  end

  @spec notify_subscribers(registry, package, version, event, event_content) ::
          :ok | {:error, term}
  defp notify_subscribers(registry, package, version, event, content) do
    Phoenix.PubSub.broadcast(
      Xray.PubSub,
      get_topic(registry, package, version),
      {__MODULE__, version, event, content}
    )
  end

  defp get_unknown_version(registry, package, version) do
    case @registry.get_versions(registry, package.name) do
      {:ok, changesets} ->
        changesets
        |> Enum.map(&Map.merge(&1, %{package_id: package.id}))
        |> Enum.each(fn p -> Repo.insert!(p, on_conflict: :nothing) end)

        case Repo.get_by(Version, package_id: package.id, version: version) do
          nil -> {:error, "version does not exist"}
          found -> {:ok, found}
        end

      {:error, error} ->
        {:error, error}
    end
  end
end
