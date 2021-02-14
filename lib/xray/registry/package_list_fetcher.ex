defmodule Xray.Registry.PackageListFetcher do
  use Oban.Worker, queue: :package_list_fetcher
  alias Xray.Packages.Package
  alias Xray.{Registry, Repo}

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"registry" => registry}}) do
    packages = Registry.get_packages!(registry)

    packages
    |> Enum.chunk_every(1000)
    |> Enum.each(fn chunk ->
      chunk_packages =
        chunk
        |> Enum.map(fn package ->
          %Package{
            name: package,
            registry: registry,
            inserted_at: DateTime.utc_now() |> DateTime.truncate(:second),
            updated_at: DateTime.utc_now() |> DateTime.truncate(:second)
          }
        end)

      Repo.insert_all(Package, chunk_packages,
        on_conflict: :nothing,
        conflict_target: [:registry, :name]
      )
    end)
  end
end
