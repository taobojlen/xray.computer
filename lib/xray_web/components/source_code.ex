defmodule XrayWeb.Components.SourceCode do
  use Surface.Component
  alias XrayWeb.Components.LoadingSpinner

  prop file_type, :string, required: true
  prop code, :string, required: true
  prop loading_formatted, :boolean

  @impl true
  def render(assigns) do
    ~F"""
    <div class="code-container">
      <LoadingSpinner :if={@loading_formatted} text={"Formatting..."} />
      <pre :if={!@loading_formatted} class="code-block"><code id="code" class={"language-#{@file_type}"} phx-hook="codeUpdated">{@code}</code></pre>
    </div>
    """
  end
end
