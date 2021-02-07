defmodule Diff.Factory do
  alias Diff.{Packages, Repo}

  # Factories

  def build(:package) do
    %Packages.Package{
      name: "package#{System.unique_integer([:positive])}",
      registry: "npm"
    }
  end

  def build(:version) do
    %Packages.Version{
      released_at: DateTime.utc_now() |> DateTime.truncate(:second),
      version:
        "#{System.unique_integer([:positive])}.#{System.unique_integer([:positive])}.#{
          System.unique_integer([:positive])
        }"
    }
  end

  def build(:package_with_versions) do
    %Packages.Package{
      name: "package#{System.unique_integer()}",
      registry: "npm",
      versions: [
        build(:version),
        build(:version),
        build(:version)
      ]
    }
  end

  # Convenience API

  def build(factory_name, attributes) do
    factory_name |> build() |> struct!(attributes)
  end

  def insert!(factory_name, attributes \\ []) do
    factory_name |> build(attributes) |> Repo.insert!()
  end
end
