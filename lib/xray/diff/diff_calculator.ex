defmodule Xray.Diff.DiffCalculator do
  use Oban.Worker,
    queue: :diff,
    unique: [period: :infinity]

  require Logger
  alias Xray.{Packages, Repo, Storage, Util}
  alias Xray.Diff.{Diff, DiffServer}

  def perform(%Oban.Job{args: %{"from_id" => from_id, "to_id" => to_id}}) do
    version_from = Packages.get_version!(from_id)
    version_to = Packages.get_version!(to_id)
    package = Packages.get_package!(version_from.package_id)

    Logger.info(
      "Calculating diff for #{package.registry}/#{package.name}/#{version_from.version}/#{version_to.version}"
    )

    # Download source
    # TODO: this could maybe be optimized so we don't need to do the whole download-from-npm,
    # upload-to-storage, download-from-storage dance. Maybe even just some filesystem-based
    # caching could help.
    from_path = download_files(version_from.tarball_key)
    to_path = download_files(version_to.tarball_key)

    with {:ok, diff_path} <- git_diff(from_path, to_path),
         {:ok, raw_diff} <- File.read(diff_path) do
      key = get_diff_key(package.registry, package.name, version_from.version, version_to.version)
      Storage.put(key, raw_diff)
      File.rm_rf!(Path.dirname(diff_path))

      Repo.insert!(%Diff{
        storage_key: key,
        version_from_id: from_id,
        version_to_id: to_id,
        from_path: from_path,
        to_path: to_path
      })

      DiffServer.notify_success(
        package.registry,
        package.name,
        version_from.version,
        version_to.version,
        key
      )

      :ok
    else
      {:error, error} ->
        Logger.error(
          "Failed to get diff for #{package.registry}/#{package.name}/#{version_from.version}/#{version_to.version} with: #{error}"
        )

      other ->
        Logger.error(
          "Failed to get diff for #{package.registry}/#{package.name}/#{version_from.version}/#{version_to.version} with: #{other}"
        )
    end
  end

  defp download_files(tarball_key) do
    destination_dir = Util.tmp_path()
    tarball_path = Util.tmp_path("tarball")

    try do
      Storage.get_to_filesystem(tarball_key, tarball_path)
      Util.extract_tgz(tarball_path, destination_dir)
    rescue
      error ->
        Logger.error("Failed to get/extract #{tarball_key}: #{error}")
        File.rm_rf!(destination_dir)
    after
      File.rm!(tarball_path)
    end

    destination_dir
  end

  defp git_diff(from_path, to_path) do
    tmp_dir = Util.tmp_path()
    diff_path = Path.join(tmp_dir, "diff.txt")
    Logger.debug("Calling git diff on #{from_path} and #{to_path}")

    case System.cmd(
           "git",
           [
             "-c",
             "core.quotePath=false",
             "-c",
             "diff.algorithm=histogram",
             "diff",
             "--no-index",
             "--no-color",
             "--output=#{diff_path}",
             from_path,
             to_path
           ],
           cd: tmp_dir
         ) do
      {"", 1} ->
        {:ok, diff_path}

      other ->
        File.rm_rf!(tmp_dir)
        {:error, other}
    end
  end

  defp get_diff_key(registry, package, version_from, version_to) do
    [registry, package, "diffs", "#{version_from}---#{version_to}.diff"]
    |> Enum.join("/")
  end
end
