defmodule Xray.Repo.Migrations.CreatePackages do
  use Ecto.Migration

  def change do
    create table(:packages) do
      add :name, :string, null: false
      add :registry, :string, null: false
      add :versions_updated_at, :utc_datetime

      timestamps()
    end

    create unique_index(:packages, [:name, :registry])

  end
end
