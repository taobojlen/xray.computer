defmodule Xray.Repo.Migrations.AddDiffUniqueIndex do
  use Ecto.Migration

  def change do
    create unique_index(:diffs, [:version_from_id, :version_to_id])
  end
end
