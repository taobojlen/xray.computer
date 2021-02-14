defmodule Xray.Factory do
  use ExMachina.Ecto, repo: Xray.Repo
  alias Xray.Packages.{Package, Version}

  def package_factory do
    %Package{
      name: sequence("package"),
      registry: sequence(:registry, Package.get_registries())
    }
  end

  def version_factory do
    version = Faker.App.semver(allow_pre: true, allow_build: true)

    %Version{
      version: version,
      package: build(:package)
    }
  end
end
