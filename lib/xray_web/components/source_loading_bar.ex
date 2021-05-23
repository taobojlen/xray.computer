defmodule XrayWeb.Components.SourceLoadingBar do
  use Surface.Component

  prop progress, :decimal, default: 1
  prop registry, :string, required: true

  @impl true
  def render(%{progress: progress} = assigns) do
    width = "#{progress * 100}%"

    ~H"""
    <section>
      <div class="mb-1 text-sm">Fetching source code from {{ @registry }}...</div>
      <div class="progress-bar-wrapper" role="progressbar" aria-valuenow={{ @progress }} aria-valuemin="0" aria-valuemax="1">
        <div class="progress-bar" style="width: {{ width }}" />
      </div>
    </section>
    """
  end
end
