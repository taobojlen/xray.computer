defmodule XrayWeb.Components.FileSelect do
  use Surface.Component
  alias XrayWeb.Components.FormLabel

  prop files, :list, required: true
  prop current_file, :string
  prop viewing_formatted, :boolean, required: true
  prop loading_formatted, :boolean, required: true
  prop select_file, :event, required: true
  prop toggle_formatted, :event, required: true

  @impl true
  def render(assigns) do
    ~F"""
    <div class="grid grid-cols-3 w-full sticky top-0 bg-gray-100 pt-2 pb-4 z-10 max-w-6xl mx-auto">
      <form
        :on-change={@select_file}
        class="col-start-2"
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
      <form
        :on-change={@toggle_formatted}
        class="justify-self-end flex items-end"
      >
        <div class="h-10 flex items-center">
          <i class="fas fa-info-circle text-gray-600 mr-1" x-data="{tooltip: 'Format code using Prettier'}" x-tooltip="tooltip" />
          <FormLabel for="formatted-checkbox">
            <div class="flex items-center cursor-pointer">
              Format
              <div class="relative ml-2">
                <input checked={@viewing_formatted} disabled={@loading_formatted} value="true" type="checkbox" id="formatted-checkbox" name="formatted" class="sr-only" />
                <div class="block bg-gray-300 border-gray-400 border w-10 h-6 rounded-full" />
                <div class="dot absolute left-1 top-1 bg-white w-4 h-4 rounded-full transition" />
              </div>
            </div>
          </FormLabel>
        </div>
      </form>
    </div>
    """
  end
end
