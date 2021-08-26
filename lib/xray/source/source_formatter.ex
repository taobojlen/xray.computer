defmodule Xray.Source.SourceFormatter do
  use Oban.Worker,
    queue: :source_formatter

  require Logger
  alias Xray.{Packages, Registry, Storage, Util}
  alias Xray.Source.FormattedSource

  @moduledoc """
  This worker gets a source code file from storage, runs a code formatter on it,
  and saves the result to storage again.
  """

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"id" => version_id, "file_key" => file_key}}) do
    version = Packages.get_version!(version_id)
    package = Packages.get_package!(version.package_id)

    Logger.info("Formatting #{package.registry}/#{package.name} v#{version.version} #{file_key}")

    filename = file_key |> String.split("/") |> List.last()
    tmp_path = Path.join([Util.tmp_path("format"), filename])

    with :ok <- Storage.get_to_filesystem(file_key, tmp_path),
         :ok <- Registry.format(package.registry, tmp_path),
         :ok <- save_formatted_source(file_key, tmp_path) do
      formatted_source = File.read!(tmp_path)
      FormattedSource.notify_found_formatted_source(version_id, file_key, formatted_source)
      :ok
    else
      {:error, error} ->
        Logger.error(
          "Failed to format #{package.registry}/#{package.name} v#{version.version} #{file_key}: #{error}"
        )

        FormattedSource.notify_error(version_id, file_key)
    end

    File.rm_rf!(tmp_path)
    :ok
  end

  defp save_formatted_source(file_key, tmp_path) do
    new_key = FormattedSource.get_formatted_storage_key(file_key)
    Storage.put_from_filesystem(new_key, tmp_path)
  end
end
