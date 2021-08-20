defmodule XrayWeb.Components.SourceCode do
  use Surface.Component

  prop file_type, :string, required: true
  prop code, :string, required: true

  @impl true
  def render(assigns) do
    ~F"""
    <div class="code-container">
      <pre class="code-block"><code id="code" class={"language-#{@file_type}"} phx-hook="codeUpdated">{@code}</code></pre>
    </div>
    """
  end
end
