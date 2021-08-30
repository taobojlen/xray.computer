defmodule Xray.Registry.PackageListFetcher do
  use Oban.Worker, queue: :package_list_fetcher
  alias Xray.Packages.Package
  alias Xray.Repo

  @registry Application.compile_env!(:xray, :registry)
  @mix_env Application.compile_env!(:xray, :mix_env)

  @impl Oban.Worker
  def perform(%Oban.Job{args: %{"registry" => registry}}) do
    @registry.get_packages!(registry)
    |> Stream.chunk_every(1000)
    |> Stream.each(fn chunk -> chunk |> Enum.to_list() |> insert_packages(registry) end)
    |> Stream.run()

    if @mix_env == :prod do
      HTTPoison.get("https://api.honeybadger.io/v1/check_in/j6IALq")
    end

    :ok
  end

  defp insert_packages(names, registry) do
    now = NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)

    packages =
      names
      |> Enum.map(fn name ->
        %{
          name: name,
          registry: registry,
          inserted_at: now,
          updated_at: now
        }
      end)

    Repo.insert_all(Package, packages,
      on_conflict: :nothing,
      conflict_target: [:registry, :name]
    )
  end
end
