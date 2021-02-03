defmodule Diff.Repo.Migrations.CreateVersions do
  use Ecto.Migration

  def change do
    create table(:versions) do
      add :version, :string
      add :published_at, :utc_datetime
      add :package_id, references(:packages), null: false

      timestamps()
    end

  end
end
