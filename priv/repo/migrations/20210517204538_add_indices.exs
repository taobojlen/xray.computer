defmodule Xray.Repo.Migrations.AddIndices do
  use Ecto.Migration

  def change do
    create(index(:packages, [:name]))
    create(index(:packages, [:registry]))
    create(index(:versions, [:package_id]))
  end
end
