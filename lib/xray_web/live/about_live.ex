defmodule XrayWeb.AboutLive do
  use Surface.LiveView
  alias XrayWeb.Components.MainPage

  @impl true
  def render(assigns) do
    ~F"""
    <MainPage title="About">
      <div class="space-y-3">
        <p>If you do your due diligence when installing or updating dependencies, you've probably
        gone to a project's GitHub to have a look at its source code. However, there's no guarantee
        that the code on GitHub is what was actually published to npm.</p>

        <p>xray.computer lets you read the exact code you'll be running when you install or update a package.
        This type of manual review is one of the tools in our arsenal when it comes to catching supply
        chain attacks like the one in
        <a href="https://snyk.io/blog/a-post-mortem-of-the-malicious-event-stream-backdoor/">event-stream</a>.
        </p>

        <p>This project borrows very heavily from <a href="https://preview.hex.pm">Hex Preview</a> and
        <a href="https://diff.hex.pm">Hex Diff</a>. It's not quite a fork, but it's not too far from it.
        Both of these tools are great parts of the Elixir ecosystem; xray.computer is an attempt to bring
        the same capability to other package registries.</p>
      </div>
    </MainPage>
    """
  end
end
