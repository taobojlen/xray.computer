defmodule Diff.Package do
  use Ecto.Schema
  import Ecto.Changeset

  schema "packages" do
    field :last_updated, :utc_datetime
    field :name, :string

    timestamps()
  end

  @doc false
  def changeset(package, attrs) do
    package
    |> cast(attrs, [:name, :last_updated])
    |> validate_required([:name, :last_updated])
  end
end
