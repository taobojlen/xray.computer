defmodule Xray.Repo.Migrations.AddVersionTarballKey do
  use Ecto.Migration

  def change do
    alter table(:versions) do
      add :tarball_key, :string
    end
  end
end
