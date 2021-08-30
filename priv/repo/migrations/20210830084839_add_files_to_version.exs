defmodule Xray.Repo.Migrations.AddFilesToVersion do
  use Ecto.Migration

  def change do
    alter table("versions") do
      add :files, :map
      remove :source_key
      remove :tarball_url
    end
  end
end
