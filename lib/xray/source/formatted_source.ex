defmodule Xray.Source.FormattedSource do
  alias Xray.Source.SourceFormatter
  alias Xray.Storage

  @topic inspect(__MODULE__)

  @spec subscribe(integer(), String.t()) :: :ok | {:error, term}
  def subscribe(version_id, file_key) do
    Phoenix.PubSub.subscribe(Xray.PubSub, get_topic(version_id, file_key))
  end

  def unsubscribe(version_id, file_key) do
    Phoenix.PubSub.unsubscribe(Xray.PubSub, get_topic(version_id, file_key))
  end

  @spec notify_found_formatted_source(integer(), String.t(), binary()) :: :ok | {:error, term}
  def notify_found_formatted_source(version_id, file_key, formatted_source) do
    Phoenix.PubSub.broadcast(
      Xray.PubSub,
      get_topic(version_id, file_key),
      {__MODULE__, version_id, file_key, formatted_source}
    )
  end

  @spec notify_error(integer(), String.t()) :: :ok | {:error, term}
  def notify_error(version_id, file_key) do
    Phoenix.PubSub.broadcast(
      Xray.PubSub,
      get_topic(version_id, file_key),
      {__MODULE__, version_id, file_key, :error}
    )
  end

  @spec get_formatted_storage_key(String.t()) :: String.t()
  def get_formatted_storage_key(file_key) do
    file_key
    |> String.split("/")
    |> List.insert_at(0, "formatted")
    |> Enum.filter(fn s -> String.trim(s) != "" end)
    |> Enum.join("/")
  end

  @doc """
  Gets the formatted source code for a given file. Results are returned
  via PubSub since fetching & formatting the source is an async process.
  """
  @spec get_formatted_file(integer(), String.t()) :: :ok
  def get_formatted_file(version_id, file_key) do
    formatted_key = get_formatted_storage_key(file_key)
    formatted_source = Storage.get(formatted_key)

    if is_nil(formatted_source) do
      %{id: version_id, file_key: file_key}
      |> SourceFormatter.new()
      |> Oban.insert()
    else
      notify_found_formatted_source(version_id, file_key, formatted_source)
    end
  end

  defp get_topic(version_id, file_key) do
    @topic <> "-#{version_id}-#{file_key}"
  end
end
