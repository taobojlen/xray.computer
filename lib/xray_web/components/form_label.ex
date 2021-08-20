defmodule XrayWeb.Components.FormLabel do
  use Surface.Component

  prop for, :string, required: true
  slot default, required: true

  @impl true
  def render(assigns) do
    ~F"""
    <label
      for={"#{@for}"}
      class="text-sm text-gray-700"
    >
      <#slot />
    </label>
    """
  end
end
