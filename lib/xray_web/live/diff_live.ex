defmodule XrayWeb.DiffLive do
  use Surface.LiveView
  alias XrayWeb.Components.MainPage

  def render(assigns) do
    ~H"""
    <MainPage title="Diff" page="diff" description="See what changed between different versions of an npm package.">
    hello
    </MainPage>
    """
  end
end
