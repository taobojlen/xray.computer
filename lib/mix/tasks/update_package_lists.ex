defmodule Mix.Tasks.UpdatePackageLists do
  use Mix.Task
  alias Xray.Registry

  @shortdoc "Updates the complete list of packages for all registries"
  @impl Mix.Task
  def run(_) do
    Mix.Task.run("app.start")

    Registry.get_registries()
    |> Enum.each(fn registry ->
      Mix.shell().info("Getting packages from #{registry}...")
      # A hack - runs Oban job directly
      # There's probably a better way to do this
      job = %Oban.Job{args: %{"registry" => registry}}
      Registry.PackageListFetcher.perform(job)
    end)
  end
end
