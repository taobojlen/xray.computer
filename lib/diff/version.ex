defmodule Diff.Version do
  use Ecto.Schema
  import Ecto.Changeset

  schema "versions" do
    field :published_at, :utc_datetime
    field :version, :string
    belongs_to :package, Diff.Package

    timestamps()
  end

  @doc false
  def changeset(version, attrs) do
    version
    |> cast(attrs, [:version, :published_at])
    |> cast_assoc(:package, with: &Diff.Package.changeset/2)
    |> validate_required([:version, :published_at])
  end
end
