defmodule XrayWeb.AboutLive do
  use Surface.LiveView
  alias XrayWeb.Components.MainPage

  @impl true
  def render(assigns) do
    ~H"""
    <MainPage title="About">
      <div class="space-y-3">
        <p>If you do your due diligence when installing new dependencies in your project, you've probably
        gone to that project's GitHub to have a look at its source code. However, there's no guarantee
        that the code on GitHub is what was actually published to npm.</p>

        <p>xray.computer is a web-based alternative to commands like
        <a href="https://docs.npmjs.com/cli/v7/commands/npm-pack"><code>npm pack</code></a>. It lets you read
        the exact code you'll be running when you install a package.</p>

        <p>This project borrows very heavily from <a href="https://preview.hex.pm">Hex Preview</a> and
        <a href="https://diff.hex.pm">Hex Diff</a>. It's not quite a fork, but it's not too far from it.
        Both of these tools are great parts of the Elixir ecosystem; xray.computer is an attempt to bring
        the same capability to other package registries.</p>
      </div>
    </MainPage>
    """
  end
end