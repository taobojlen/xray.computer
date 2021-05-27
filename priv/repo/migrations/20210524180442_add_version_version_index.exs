defmodule Xray.Repo.Migrations.AddVersionVersionIndex do
  use Ecto.Migration

  def change do
    create(index(:versions, [:version]))
  end
end
