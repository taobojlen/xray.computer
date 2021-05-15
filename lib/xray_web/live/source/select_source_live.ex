defmodule XrayWeb.SelectSourceLive do
  alias Xray.Registry
  use XrayWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     assign(socket, registry: "npm", package: nil, suggestions: [], page_title: "View source")}
  end

  @impl true
  def handle_event("type", %{"p" => package}, %{assigns: %{registry: registry}} = socket) do
    suggestions = get_suggestions(registry, package)

    {:noreply,
     assign(socket,
       package: package,
       suggestions: suggestions
     )}
  end

  @impl true
  def handle_event(
        "select_package",
        %{"package" => package},
        socket
      ) do
    {:noreply, assign(socket, package: package)}
  end

  defp get_suggestions(registry, query) do
    Registry.search(registry, query)
    |> Enum.slice(0, 3)
  end
end
