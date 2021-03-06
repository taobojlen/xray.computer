defmodule Xray.VersionListFetcher do
  alias Xray.Registry

  def subscribe(registry, package) do
    topic = get_topic(registry, package)
    Phoenix.PubSub.subscribe(Xray.PubSub, topic)
  end

  def unsubscribe(registry, package) do
    Phoenix.PubSub.unsubscribe(Xray.PubSub, get_topic(registry, package))
  end

  def get_versions(registry, package) do
    topic = get_topic(registry, package)

    case Registry.get_versions(registry, package) do
      {:ok, versions} ->
        versions = versions |> Enum.map(fn v -> Map.get(v, :version) end)
        Phoenix.PubSub.broadcast(Xray.PubSub, topic, {__MODULE__, :got_versions, versions})

      _other ->
        # TODO: show error
        Phoenix.PubSub.broadcast(Xray.PubSub, topic, {__MODULE__, :got_versions, []})
    end
  end

  defp get_topic(registry, package) do
    inspect(__MODULE__) <> "-#{registry}-#{package}-versions"
  end
end
