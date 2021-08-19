defmodule Xray.Packages.Package do
  use Ecto.Schema
  import Ecto.Changeset

  @registries [
    "npm"
  ]

  schema "packages" do
    field(:name, :string)
    field(:registry, :string)
    field(:versions_updated_at, :utc_datetime)
    has_many(:versions, Xray.Packages.Version)

    timestamps()
  end

  @doc false
  def changeset(package, attrs) do
    package
    |> cast(attrs, [:name, :registry, :versions_updated_at])
    |> validate_required([:name, :registry])
    |> validate_inclusion(:registry, @registries)
    |> unique_constraint([:registry, :name])
  end

  def get_registries do
    @registries
  end
end
