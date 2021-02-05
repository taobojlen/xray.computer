defmodule Diff.Packages.Package do
  use Ecto.Schema
  import Ecto.Changeset

  schema "packages" do
    field :name, :string
    field :registry, :string
    field :versions_updated_at, :utc_datetime
    has_many :versions, Diff.Packages.Version

    timestamps()
  end

  @doc false
  def changeset(package, attrs) do
    package
    |> cast(attrs, [:name, :registry, :versions_updated_at])
    |> validate_required([:name, :registry])
    |> validate_inclusion(:registry, ["npm"])
  end
end
