defmodule Diff.Packages.Version do
  use Ecto.Schema
  import Ecto.Changeset

  schema "versions" do
    field :released_at, :utc_datetime
    field :version, :string
    field :source_uri, :string
    field :tarball_url, :string
    belongs_to :package, Diff.Packages.Package

    timestamps()
  end

  @doc false
  def changeset(version, attrs) do
    version
    |> cast(attrs, [:version, :released_at, :source_uri, :tarball_url])
    |> validate_required([:version])
  end
end
