defmodule Xray.VersionListFetcher do
  alias Xray.{Packages, Registry, Repo}
  alias Xray.Packages.{Package, Version}

  @type registry :: String.t()

  @spec subscribe(registry, String.t()) :: :ok | {:error, term()}
  def subscribe(registry, package) do
    topic = get_topic(registry, package)
    Phoenix.PubSub.subscribe(Xray.PubSub, topic)
  end

  @spec unsubscribe(registry, String.t()) :: :ok
  def unsubscribe(registry, package) do
    Phoenix.PubSub.unsubscribe(Xray.PubSub, get_topic(registry, package))
  end

  @spec get_versions(registry, Package.t()) :: :ok | {:error, term()}
  def get_versions(registry, package) do
    topic = get_topic(registry, package.name)

    case Registry.get_versions(registry, package.name) do
      {:ok, versions} ->
        versions = versions |> Enum.map(fn v -> Map.get(v, :version) end)
        save_versions(versions, package)

        Phoenix.PubSub.broadcast(Xray.PubSub, topic, {__MODULE__, :got_versions, versions})

      _other ->
        # TODO: show error
        Phoenix.PubSub.broadcast(Xray.PubSub, topic, {__MODULE__, :got_versions, []})
    end
  end

  @spec get_topic(registry, String.t()) :: String.t()
  defp get_topic(registry, package) do
    inspect(__MODULE__) <> "-#{registry}-#{package}-versions"
  end

  defp save_versions(versions, package) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    version_structs =
      versions
      |> Enum.map(fn v ->
        %{
          version: v,
          package_id: package.id,
          inserted_at: now,
          updated_at: now
        }
      end)

    Repo.insert_all(Version, version_structs,
      on_conflict: :nothing,
      conflict_target: [:version, :package_id]
    )

    Packages.update_package(package, %{versions_updated_at: now})
  end
end
