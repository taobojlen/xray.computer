defmodule Xray.Diff.Diff do
  use Ecto.Schema
  import Ecto.Changeset

  schema "diffs" do
    field :storage_key, :string
    field :from_path, :string
    field :to_path, :string
    field :version_from_id, :id
    field :version_to_id, :id

    timestamps()
  end

  @doc false
  def changeset(diff, attrs) do
    diff
    |> cast(attrs, [:storage_key, :from_path, :to_path])
    |> validate_required([:storage_key, :from_path, :to_path])
  end
end
