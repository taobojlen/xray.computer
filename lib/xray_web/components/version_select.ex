defmodule XrayWeb.Components.VersionSelect do
  use Surface.Component

  alias XrayWeb.Components.{FormLabel, LoadingSpinner}

  prop select_id, :string, default: "version-select"
  prop label, :string, default: "Version"
  prop version, :string, default: nil
  prop versions, :list, default: nil
  prop loading, :boolean, default: true
  prop select_version, :event, required: true

  @impl true
  def render(assigns) do
    ~H"""
    <div class="mt-4">
      <LoadingSpinner :if={{ @loading }} />
      <form
        :if={{ not @loading and not Enum.empty?(@versions) }}
        :on-change={{ @select_version }}
      >
        <FormLabel for="{{ @select_id }}">{{ @label }}</FormLabel>
        <select
          name="version"
          id={{ @select_id }}
          class="select mb-2 w-72"
        >
          <option
            :for={{version <- @versions}}
            value={{ version }}
          >
            {{ version }}
          </option>
        </select>
      </form>
    </div>
    """
  end
end
