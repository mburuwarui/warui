defmodule WaruiWeb.Components.Overlay do
  @moduledoc """
  The `WaruiWeb.Components.Overlay` module provides a versatile overlay component for
  Phoenix LiveView applications, allowing developers to create layered content effects.
  It supports various customization options, including color themes, opacity levels,
  and blur effects, which enable the creation of visually engaging overlays.

  This component is designed to be highly adaptable, offering predefined color themes,
  opacity variations, and blur sizes to match the needs of different interface designs.
  The `WaruiWeb.Components.Overlay` is perfect for creating modal backgrounds, loading screens,
  and other interactive elements that require content layering.
  """

  use Phoenix.Component

  @sizes ["extra_small", "small", "medium", "large", "extra_large"]
  @colors [
    "natural",
    "white",
    "dark",
    "primary",
    "secondary",
    "success",
    "warning",
    "danger",
    "info",
    "silver",
    "misc",
    "dawn"
  ]

  @opacities [
    "transparent",
    "translucent",
    "semi_transparent",
    "lightly_tinted",
    "tinted",
    "semi_opaque",
    "opaque",
    "heavily_tinted",
    "almost_solid"
  ]

  @doc """
  Renders an `overlay` element with customizable color, opacity, and blur options.

  The overlay can be used to create various visual effects such as loading screens or background dimming.

  ## Examples

  ```elixir
  <.overlay color="misc" opacity="semi_opaque" />

  <.overlay color="dawn" opacity="semi_opaque">
    <div class="flex justify-center items-center gap-2 h-full">
      <.spinner color="natural" size="large" />
      <div class="text-white">Loading...</div>
    </div>
  </.overlay>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "natural", doc: "Determines color theme"
  attr :opacity, :string, values: @opacities ++ [nil], default: nil, doc: ""
  attr :blur, :string, values: @sizes ++ ["none", nil], default: nil, doc: ""
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  @spec overlay(map()) :: Phoenix.LiveView.Rendered.t()
  def overlay(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "absolute inset-0 z-50",
        color_class(@color),
        opacity_class(@opacity),
        blur_class(@blur),
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  defp color_class("white") do
    ["bg-white text-black"]
  end

  defp color_class("dark") do
    ["bg-[#282828] text-white"]
  end

  defp color_class("natural") do
    ["bg-[#4B4B4B] dark:bg-[#DDDDDD]"]
  end

  defp color_class("primary") do
    ["bg-[#007F8C] dark:bg-[#01B8CA]"]
  end

  defp color_class("secondary") do
    ["bg-[#266EF1] dark:bg-[#6DAAFB]"]
  end

  defp color_class("success") do
    ["bg-[#0E8345] dark:bg-[#06C167]"]
  end

  defp color_class("warning") do
    ["bg-[#CA8D01] dark:bg-[#FDC034]"]
  end

  defp color_class("danger") do
    ["bg-[#DE1135] dark:bg-[#FC7F79]"]
  end

  defp color_class("info") do
    ["bg-[#0B84BA] dark:bg-[#3EB7ED]"]
  end

  defp color_class("misc") do
    ["bg-[#8750C5] dark:bg-[#BA83F9]"]
  end

  defp color_class("dawn") do
    ["bg-[#A86438] dark:bg-[#DB976B]"]
  end

  defp color_class("silver") do
    ["bg-[#868686] dark:bg-[#A6A6A6]"]
  end

  defp color_class(params) when is_binary(params), do: params

  defp opacity_class("transparent") do
    "bg-opacity-10"
  end

  defp opacity_class("translucent") do
    "bg-opacity-20"
  end

  defp opacity_class("semi_transparent") do
    "bg-opacity-30"
  end

  defp opacity_class("lightly_tinted") do
    "bg-opacity-40"
  end

  defp opacity_class("tinted") do
    "bg-opacity-50"
  end

  defp opacity_class("semi_opaque") do
    "bg-opacity-60"
  end

  defp opacity_class("opaque") do
    "bg-opacity-70"
  end

  defp opacity_class("heavily_tinted") do
    "bg-opacity-80"
  end

  defp opacity_class("almost_solid") do
    "bg-opacity-90"
  end

  defp opacity_class("solid") do
    "bg-opacity-100"
  end

  defp opacity_class(params) when is_binary(params), do: params
  defp opacity_class(_), do: nil

  defp blur_class("extra_small") do
    "backdrop-blur-[1px]"
  end

  defp blur_class("small") do
    "backdrop-blur-[2px]"
  end

  defp blur_class("medium") do
    "backdrop-blur-[3px]"
  end

  defp blur_class("large") do
    "backdrop-blur-[4px]"
  end

  defp blur_class("extra_large") do
    "backdrop-blur-[5px]"
  end

  defp blur_class(params) when is_binary(params), do: params
  defp blur_class(_), do: nil
end