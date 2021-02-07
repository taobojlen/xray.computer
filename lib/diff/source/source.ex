defmodule Diff.Source do
  @spec get_storage_key(String.t(), String.t(), String.t()) :: String.t()
  def get_storage_key(registry, package, version) do
    "#{registry}/#{package}/#{version}"
  end

  @spec get_files_list_key(String.t(), String.t(), String.t()) :: String.t()
  def get_files_list_key(registry, package, version) do
    "files_lists/#{registry}/#{package}/#{version}.txt"
  end
end
