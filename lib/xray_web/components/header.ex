defmodule XrayWeb.Components.Header do
  use Surface.Component
  alias Surface.Components.LiveRedirect

  prop page, :string

  @impl true
  def render(%{page: page} = assigns) do
    diff_active = page == "diff"
    source_active = page == "source"

    ~H"""
    <header class="flex flex-col items-center mt-6">
      <LiveRedirect to="/" class="no-underline mb-3">
        <h1 class="text-2xl font-bold">xray.computer</h1>
      </LiveRedirect>
      <nav role="navigation" class="flex items-center mb-10 space-x-4 hidden">
        <LiveRedirect to="/diff" class={{ "link-button", active: diff_active }}>Diff</LiveRedirect>
        <LiveRedirect to="/source" class={{ "link-button", active: source_active }}>Source</LiveRedirect>
      </nav>
    </header>
    """
  end
end
