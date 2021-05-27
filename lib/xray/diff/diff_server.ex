defmodule Xray.Diff.DiffServer do
  @moduledoc """
  Responsible for getting a diff between two versions of a package.

  There are two async parts to getting a diff: (1) getting the source code
  for each version, and (2) calculating the diff.
  This module handles both, and sends progress updates via PubSub.
  """
  use GenServer

  alias Xray.Diff
  alias Xray.Diff.DiffCalculator
  alias Xray.{Packages, Source}

  @topic __MODULE__

  # Public API

  @spec get_diff(String.t(), String.t(), String.t(), String.t()) :: :ok
  def get_diff(registry, package, version_from, version_to) do
    with version_from_record when not is_nil(version_from_record) <-
           Packages.get_version(registry, package, version_from),
         version_to_record when not is_nil(version_to_record) <-
           Packages.get_version(registry, package, version_to),
         diff when not is_nil(diff) <-
           Diff.get_diff(registry, package, version_from, version_to) do
      notify_success(
        registry,
        package,
        version_from,
        version_to,
        diff.storage_key
      )
    else
      _ ->
        GenServer.start_link(__MODULE__, %{
          registry: registry,
          package: package,
          version_from: version_from,
          version_to: version_to
        })
    end

    :ok
  end

  def subscribe(registry, package, version_from, version_to) do
    Phoenix.PubSub.subscribe(Xray.PubSub, get_topic(registry, package, version_from, version_to))
  end

  def unsubscribe(registry, package, version_from, version_to) do
    Phoenix.PubSub.unsubscribe(
      Xray.PubSub,
      get_topic(registry, package, version_from, version_to)
    )
  end

  def notify_success(registry, package, version_from, version_to, diff_key) do
    notify_subscribers(registry, package, version_from, version_to, :got_diff, diff_key)
  end

  # GenServer functions

  @impl true
  def init(
        %{
          registry: registry,
          package: package,
          version_from: version_from,
          version_to: version_to
        } = state
      ) do
    Source.subscribe(registry, package, version_from)
    Source.subscribe(registry, package, version_to)
    Task.start_link(fn -> Source.get_source(registry, package, version_from) end)
    Task.start_link(fn -> Source.get_source(registry, package, version_to) end)

    state =
      Map.merge(state, %{
        version_with_source_id: %{
          version_from => nil,
          version_to => nil
        },
        progress: %{
          version_from => 0,
          version_to => 0
        }
      })

    {:ok, state}
  end

  @impl true
  def handle_info(
        {Source, version, :not_found, _content},
        %{
          registry: registry,
          package: package,
          version_from: version_from,
          version_to: version_to
        } = state
      ) do
    Source.unsubscribe(registry, package, version_from)
    Source.unsubscribe(registry, package, version_to)

    notify_subscribers(
      registry,
      package,
      version_from,
      version_to,
      :error,
      "#{version} not found"
    )

    {:stop, :error, state}
  end

  @impl true
  def handle_info(
        {Source, _version, :error, error},
        %{
          registry: registry,
          package: package,
          version_from: version_from,
          version_to: version_to
        } = state
      ) do
    Source.unsubscribe(registry, package, version_from)
    Source.unsubscribe(registry, package, version_to)
    notify_subscribers(registry, package, version_from, version_to, :error, error)
    {:stop, :error, state}
  end

  @impl true
  def handle_info(
        {Source, version, :progress, version_progress},
        %{
          registry: registry,
          package: package,
          version_from: version_from,
          version_to: version_to,
          progress: progress_map
        } = state
      ) do
    progress_map = Map.put(progress_map, version, version_progress)
    total_progress = (progress_map |> Map.values() |> Enum.sum()) / 2

    state = Map.put(state, :progress, progress_map)
    notify_subscribers(registry, package, version_from, version_to, :progress, total_progress)

    {:noreply, state}
  end

  @impl true
  def handle_info(
        {Source, version, :found_source, version_id},
        %{
          registry: registry,
          package: package,
          version_from: version_from,
          version_to: version_to,
          version_with_source_id: version_with_source_id,
          progress: progress
        } = state
      ) do
    version_with_source_id = Map.put(version_with_source_id, version, version_id)

    # Get diff if we have both versions
    if version_with_source_id |> Map.values() |> Enum.all?(&Kernel.is_integer/1) do
      notify_subscribers(registry, package, version_from, version_to, :found_source, nil)

      version_from_id = version_with_source_id |> Map.get(version_from)
      version_to_id = version_with_source_id |> Map.get(version_to)

      %{from_id: version_from_id, to_id: version_to_id}
      |> DiffCalculator.new()
      |> Oban.insert!()
    end

    progress = Map.put(progress, version, 1)

    state =
      state
      |> Map.put(:version_with_source_id, version_with_source_id)
      |> Map.put(:progress, progress)

    {:noreply, state}
  end

  # Helpers

  defp get_topic(registry, package, version_from, version_to) do
    "#{@topic}-#{registry}-#{package}-#{version_from}-#{version_to}"
  end

  defp notify_subscribers(registry, package, version_from, version_to, event, content) do
    Phoenix.PubSub.broadcast(
      Xray.PubSub,
      get_topic(registry, package, version_from, version_to),
      {__MODULE__, event, content}
    )
  end
end
