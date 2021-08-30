defmodule Xray.Diff do
  import Ecto.Query

  alias Xray.Diff.Diff
  alias Xray.Packages.{Package, Version}
  alias Xray.Repo

  @spec get_diff(String.t(), String.t(), String.t(), String.t()) :: Diff.t() | nil
  def get_diff(registry, package, version_from, version_to) do
    Repo.one(
      from d in Diff,
        join: v_from in Version,
        on: d.version_from_id == v_from.id,
        join: v_to in Version,
        on: d.version_to_id == v_to.id,
        join: p in Package,
        where:
          p.registry == ^registry and p.name == ^package and v_from.version == ^version_from and
            v_to.version == ^version_to
    )
  end

  def create_diff(attrs \\ %{}) do
    %Diff{}
    |> Diff.changeset(attrs)
    |> Repo.insert()
  end
end
