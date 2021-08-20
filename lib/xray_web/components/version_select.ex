defmodule XrayWeb.Components.VersionSelect do
  use Surface.Component

  alias XrayWeb.Components.FormLabel

  prop label, :string, default: "Version"
  prop selected_version, :string, default: nil
  prop versions, :list, default: nil
  prop select_version, :event, required: true

  @impl true
  def render(%{label: label} = assigns) do
    select_id = "version-select-#{label}"

    ~F"""
    <form :on-change={@select_version}>
      <FormLabel for={select_id}>{@label}</FormLabel>
      <select
        name="version"
        id={select_id}
        class="select mb-2 w-56"
      >
        <option
          :for={version <- @versions}
          value={version}
          selected={version == @selected_version}
        >
          {version}
        </option>
      </select>
    </form>
    """
  end
end
