defmodule XrayWeb.Components.ErrorCallout do
  use Surface.Component

  prop text, :string, required: true

  @impl true
  def render(assigns) do
    ~F"""
    <div
      x-data="{ showing: true }"
      x-show="showing"
      class="bg-red-100 rounded-lg w-full px-4 py-2 border-2 border-red-200 flex items-center justify-between"
    >
      <div class="flex items-center">
        <i class="fas fa-exclamation-circle fa-2x text-red-300" />
        <span class="ml-4 text-gray-800">{@text}</span>
      </div>
      <button @click="showing = false">
        <i class="fas fa-times text-gray-500" />
      </button>
    </div>
    """
  end
end
