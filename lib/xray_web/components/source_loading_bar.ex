defmodule XrayWeb.Components.SourceLoadingBar do
  use Surface.Component

  prop progress, :decimal, default: 1
  prop registry, :string, required: true
  prop status_text, :string

  @impl true
  def render(%{registry: registry, progress: progress, status_text: status_text} = assigns) do
    width = "#{progress * 100}%"

    status_text =
      if is_nil(status_text) do
        "Fetching source code from #{registry}..."
      else
        status_text
      end

    ~F"""
    <section class="w-56 mx-auto">
      <div class="mb-1 text-sm">{status_text}</div>
      <div class="progress-bar-wrapper" role="progressbar" aria-valuenow={@progress} aria-valuemin="0" aria-valuemax="1">
        <div class="progress-bar" style={"width: #{width}"} />
      </div>
    </section>
    """
  end
end
