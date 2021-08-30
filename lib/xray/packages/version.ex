defmodule Xray.Packages.Version do
  use Ecto.Schema
  import Ecto.Changeset

  schema "versions" do
    field :released_at, :utc_datetime
    field :version, :string
    field :files, :map
    field :tarball_key, :string
    belongs_to :package, Xray.Packages.Package

    timestamps()
  end

  @doc false
  def changeset(version, attrs) do
    version
    |> cast(attrs, [:version, :released_at, :files, :tarball_key])
    |> validate_required([:version])
  end
end
