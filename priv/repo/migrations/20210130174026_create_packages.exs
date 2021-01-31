defmodule Diff.Repo.Migrations.CreatePackages do
  use Ecto.Migration

  def change do
    create table(:packages) do
      add :name, :string, null: false
      add :last_updated, :utc_datetime

      timestamps()
    end

  end
end
