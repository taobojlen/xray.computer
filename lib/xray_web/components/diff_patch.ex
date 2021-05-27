defmodule XrayWeb.Components.DiffPatch do
  use Surface.Component
  alias Surface.Components.Raw

  # https://hexdocs.pm/git_diff/GitDiff.Patch.html

  prop patch, :struct, required: true

  @impl true
  def render(%{patch: patch} = assigns) do
    lines = patch_to_lines(patch)

    ~H"""
    <div x-data="{ open: true }" class="bg-code-bg text-code-text rounded border border-gray-400">
      <div
        @click="open = !open"
        class="py-2 px-4 bg-gray-800 font-mono cursor-pointer flex items-center justify-between border-b border-gray-500 sticky top-0"
      >
        <span>{{ @patch.from }}</span>
        <div class="text-gray-400">
          <#Raw><template x-if="open"></#Raw><i class="fas fa-angle-up" /><#Raw></template></#Raw>
          <#Raw><template x-if="!open"></#Raw><i class="fas fa-angle-down" /><#Raw></template></#Raw>
        </div>
      </div>
      <div
        x-show="open"
        class="overflow-x-auto"
      >
        <table>
          <tbody>
            <tr :for={{ line <- lines }} class={{ "diff-line", line.class }}>
              <td class="line-number">{{ line.from_line_number }}</td>
              <td class="line-number">{{ line.to_line_number }}</td>
              <td class="line-type">{{ line.type }}</td>
              <td class={{ "w-full", "text-white": not is_nil(line.type) }}><pre>{{ line.text }}</pre></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  defp patch_to_lines(%GitDiff.Patch{chunks: chunks}) do
    Enum.reduce(chunks, [], fn chunk, acc ->
      Enum.concat(acc, chunk_to_lines(chunk))
    end)
  end

  defp chunk_to_lines(chunk) do
    lines =
      Enum.reduce(chunk.lines, [], fn line, acc ->
        {class, type} =
          case line.type do
            :add -> {"line-add", "+"}
            :remove -> {"line-remove", "-"}
            :context -> {nil, nil}
          end

        line =
          Map.merge(line, %{
            class: class,
            type: type,
            text: String.slice(line.text, 1..-1)
          })

        [line | acc]
      end)

    header = %{
      from_line_number: nil,
      to_line_number: nil,
      line_status: nil,
      type: nil,
      class: "line-header",
      text: chunk.header
    }

    [header | Enum.reverse(lines)]
  end
end
