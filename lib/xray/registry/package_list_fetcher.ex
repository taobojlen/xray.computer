defmodule Xray.Registry.PackageListFetcher do
  use Oban.Worker, queue: :package_list_fetcher
  alias Xray.Packages.Package
  alias Xray.Repo

  @registry Application.compile_env!(:xray, :registry)

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"registry" => registry}}) do
    packages = @registry.get_packages!(registry)

    packages
    |> Enum.chunk_every(1000)
    |> Enum.each(fn chunk -> insert_packages(chunk, registry) end)
  end

  defp insert_packages(names, registry) do
    packages =
      names
      |> Enum.map(fn name ->
        %{
          name: name,
          registry: registry,
          inserted_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second),
          updated_at: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
        }
      end)

    Repo.insert_all(Package, packages,
      on_conflict: :nothing,
      conflict_target: [:registry, :name]
    )
  end
end
