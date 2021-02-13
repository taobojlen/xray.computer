defmodule Xray.Scheduler do
  use Quantum, otp_app: :xray
  alias Xray.Registry

  def update_package_lists do
    Registry.get_registries()
    |> Enum.each(fn registry ->
      %{registry: registry}
      |> Registry.PackageListFetcher.new()
      |> Oban.insert()
    end)
  end
end
