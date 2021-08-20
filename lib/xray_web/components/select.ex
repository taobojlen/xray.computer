defmodule XrayWeb.Components.Select do
  use Surface.Component
  alias Surface.Components.Form.Select

  prop options, :list, required: true

  @impl true
  def render(%{options: options} = assigns) do
    yolo = options

    ~F"""
    <Select form="value" options={yolo} class="select" />
    """
  end
end
