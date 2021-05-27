defmodule Xray.Repo.Migrations.CreateDiffs do
  use Ecto.Migration

  def change do
    create table(:diffs) do
      add :storage_key, :string
      add :from_path, :string
      add :to_path, :string
      add :version_from_id, references(:versions, on_delete: :nothing)
      add :version_to_id, references(:versions, on_delete: :nothing)

      timestamps()
    end

    create index(:diffs, [:version_from_id])
    create index(:diffs, [:version_to_id])
  end
end
