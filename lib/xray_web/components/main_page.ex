defmodule XrayWeb.Components.MainPage do
  use Surface.Component
  alias Surface.Components.LivePatch

  alias XrayWeb.Components.Header

  prop page, :string, values: ["diff", "source"]
  prop title, :string, required: true
  prop subtitle, :string
  prop description, :string, required: false
  prop wide, :boolean, default: false
  slot default, required: true
  slot custom_title

  @impl true
  def render(%{wide: wide} = assigns) do
    width_class = if wide, do: "max-w-7xl", else: "max-w-xl"

    ~F"""
    <div>
      <Header page={@page} />
      <main class="flex flex-col items-center mx-2 items-stretch">
        <div class="mb-3 text-center">
          <h2 class="text-xl font-bold">
            <#slot name="custom_title">
              {@title}
            </#slot>
          </h2>
          <p :if={@subtitle} class="text-gray-600">{@subtitle}</p>
        </div>

        <p :if={@description} class="mb-10 text-gray-800 text-center max-w-md mx-auto w-full">
        {@description} <LivePatch to="/about">Why?</LivePatch>
        </p>

        <article class={width_class, "mx-auto", "w-full"}>
          <#slot />
        </article>
      </main>
    </div>
    """
  end
end
