defmodule XrayWeb.Components.DiffPatch do
  use Surface.Component

  # https://hexdocs.pm/git_diff/GitDiff.Patch.html

  prop patch, :struct, required: true

  @impl true
  def render(%{patch: patch} = assigns) do
    lines = patch_to_lines(patch)
    {change_type, filename, filename_after} = change_type(patch)

    ~F"""
    <div x-data="{ open: true }" class="bg-code-bg text-code-text rounded border border-gray-400" phx-hook="codeUpdated" id={filename}>
      <div
        @click="open = !open"
        class="py-2 px-4 bg-gray-800 font-mono cursor-pointer flex items-center justify-between border-b border-gray-500 sticky top-0"
      >
        <div>
          <span
            :if={change_type != :changed}
            class="border border-gray-400 bg-gray-500 text-gray-200 rounded p-1 text-xs font-sans uppercase mr-2"
          >
            {change_type}
          </span>
          <span>{filename}</span>
          <span :if={not is_nil(filename_after)}>
            <i class="fas fa-long-arrow-alt-right" />
            {filename_after}
          </span>
        </div>
        <div class="text-gray-400">
          <template x-if="open"><i class="fas fa-angle-up" /></template>
          <template x-if="!open"><i class="fas fa-angle-down" /></template>
        </div>
      </div>
      <div
        x-show="open"
        class="overflow-x-auto"
      >
        <table>
          <tbody>
            <tr :for={{line, index} <- Enum.with_index(lines)} class={"diff-line", line.class} id={"#{filename}-#{index}"}>
              <td class="line-number">
                <div class="inline-block w-6">{line.from_line_number}</div>
                <div class="inline-block w-6">{line.to_line_number}</div>
              </td>
              <td class="line-type">{line.type}</td>
              <td class={"w-full", "text-white": not is_nil(line.type)}><pre>{line.text}</pre></td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    """
  end

  defp change_type(%GitDiff.Patch{from: from, to: to}) do
    case {from, to} do
      {nil, to} -> {:created, to, nil}
      {from, nil} -> {:deleted, from, nil}
      {from, to} when from == to -> {:changed, to, nil}
      {from, to} -> {:renamed, from, to}
    end
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
