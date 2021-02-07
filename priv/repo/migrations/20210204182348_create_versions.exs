defmodule Diff.Repo.Migrations.CreateVersions do
  use Ecto.Migration

  def change do
    create table(:versions) do
      add :version, :string, null: false
      add :released_at, :utc_datetime
      add :source_key, :string
      add :tarball_url, :string
      add :package_id, references(:packages, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:versions, [:package_id, :version])

  end
end
