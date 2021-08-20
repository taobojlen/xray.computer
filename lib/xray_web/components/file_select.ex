defmodule XrayWeb.Components.FileSelect do
  use Surface.Component
  alias XrayWeb.Components.FormLabel

  prop files, :list, required: true
  prop current_file, :string
  prop select_file, :event, required: true

  @impl true
  def render(assigns) do
    ~F"""
    <div class="flex items-center justify-center w-full sticky top-0 bg-gray-100 pt-2 pb-4 z-10">
      <form
        :on-change={@select_file}
      >
        <FormLabel for="file">File</FormLabel>
        <select
          name="file"
          id="file"
          class="select"
        >
          <option
            :for={filename <- @files}
            value={filename}
            selected={filename == @current_file}
          >
            {filename}
          </option>
        </select>
      </form>
    </div>
    """
  end
end
