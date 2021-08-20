defmodule XrayWeb.Components.PackageSearchField do
  use Surface.LiveComponent

  alias Xray.Registry
  alias XrayWeb.Components.FormLabel

  @default_suggestions ["lodash", "react", "chalk", "axios"]

  prop registry, :string, required: true, values: Registry.get_registries()
  prop package, :string, required: true

  data suggestions, :list, default: @default_suggestions

  @impl true
  def render(%{package: package} = assigns) do
    suggestion_text = if package == nil, do: "Suggestions", else: "Did you mean?"

    ~F"""
    <form :on-change="type">
      <span class="sr-only"><FormLabel for="package-input">Package</FormLabel></span>
      <input
        value={@package}
        id="package-input"
        type="text"
        name="package"
        placeholder="Search for a package"
        autocomplete="off"
        autofocus="true"
        phx-debounce="300"
        class="block p-2 mb-4 w-72 rounded shadow border border-gray-300"
      />
      <div :if={not Enum.empty?(@suggestions)} class="w-72">
        <p class="text-sm text-gray-700">{suggestion_text}</p>
        <button
          :for={suggestion <- @suggestions}
          :on-click="select_suggestion"
          phx-value-package={suggestion}
          title={suggestion}
          type="button"
          class="suggestion-button"
        >
          {suggestion}
        </button>
      </div>
    </form>
    """
  end

  @impl true
  def handle_event(
        "type",
        %{"package" => package},
        %{assigns: %{registry: registry}} = socket
      ) do
    notify_parent_liveview(package)

    suggestions =
      if package == nil or package == "", do: @default_suggestions, else: get_suggestions(registry, package)

    {:noreply,
     assign(socket,
       package: package,
       suggestions: suggestions
     )}
  end

  @impl true
  def handle_event(
        "select_suggestion",
        %{"package" => package},
        socket
      ) do
    notify_parent_liveview(package)
    {:noreply, assign(socket, package: package, suggestions: [])}
  end

  defp get_suggestions(registry, query) do
    Registry.search(registry, query)
    |> Enum.slice(0, 3)
  end

  defp notify_parent_liveview(package) do
    # send the selected package to the parent liveview
    send(self(), {:select_package, package})
  end
end
