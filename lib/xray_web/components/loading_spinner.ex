defmodule XrayWeb.Components.LoadingSpinner do
  use Surface.Component

  @impl true
  def render(assigns) do
    ~F"""
    <div class="flex flex-col items-center mt-6">
      <div class="loading-spinner" aria-hidden="true" />
      <span class="text-gray-500 text-sm mt-2">Fetching versions...</span>
    </div>
    """
  end
end
