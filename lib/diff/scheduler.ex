defmodule Diff.Scheduler do
  use Quantum, otp_app: :diff
  alias Diff.Registry

  def update_package_lists do
    Registry.get_registries()
    |> Enum.each(fn registry ->
      %{registry: registry}
      |> Registry.PackageListFetcher.new()
      |> Oban.insert()
    end)
  end
end
