defmodule WaruiWeb.Components.List do
  @moduledoc """
  The `MishkaWeb.Components.List` module provides a versatile and customizable list
  component for building both ordered and unordered lists, as well as a list
  group component for more structured content. This module is designed to cater to
  various styles and use cases, such as navigation menus, data presentations, or simple item listings.

  ### Features

  - **Styling Variants:** The component offers multiple variants like `default`,
  `bordered`, `outline`, `outline_separated`, `bordered_seperated`, and `transparent` to meet diverse design requirements.
  - **Color Customization:** Choose from a variety of colors to style the list according to
  your application's theme.
  - **Flexible Layouts:** Control the size, spacing, and appearance of list items with extensive
  customization options.
  - **Nested Structure:** Easily nest lists and group items together with the list group
  component for more complex layouts.

  This module is ideal for creating well-structured and visually appealing lists in
  your Phoenix LiveView applications.
  """

  use Phoenix.Component

  @sizes ["extra_small", "small", "medium", "large", "extra_large"]
  @variants [
    "default",
    "bordered",
    "outline",
    "shadow",
    "gradient",
    "outline_separated",
    "bordered_seperated",
    "transparent"
  ]

  @colors [
    "natural",
    "white",
    "primary",
    "secondary",
    "dark",
    "success",
    "warning",
    "danger",
    "info",
    "silver",
    "misc",
    "dawn"
  ]

  @doc """
  Renders a `list` component that supports both ordered and unordered lists with customizable styles,
  sizes, and colors.

  ## Examples

  ```elixir
  <.list font_weight="font-bold" color="silver" size="small">
    <:item padding="small" count={1}>list count small</:item>
    <:item padding="small" count={2}>list count small</:item>
    <:item padding="small" count={3}>list count small</:item>
    <:item padding="small" count={23658}>list count small</:item>
  </.list>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :size, :string,
    default: "large",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :space, :string, values: @sizes ++ [nil], default: nil, doc: "Space between items"
  attr :border, :string, values: @sizes, default: "extra_small", doc: "Border size"
  attr :color, :string, values: @colors, default: "natural", doc: "Determines color theme"
  attr :variant, :string, values: @variants, default: "transparent", doc: "Determines the style"
  attr :style, :string, default: "list-none", doc: ""
  slot :item, validate_attrs: false, doc: "Specifies item slot of a list"

  attr :rest, :global,
    include: ~w(ordered unordered),
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, doc: "Inner block that renders HEEx content"

  def list(%{rest: %{ordered: true}} = assigns) do
    ~H"""
    <.ol {assigns}>
      <.li :for={item <- @item} {item}>
        {render_slot(item)}
      </.li>
      {render_slot(@inner_block)}
    </.ol>
    """
  end

  def list(assigns) do
    ~H"""
    <.ul {assigns}>
      <.li :for={item <- @item} {item}>
        {render_slot(item)}
      </.li>
      {render_slot(@inner_block)}
    </.ul>
    """
  end

  @doc """
  Renders a list item (`li`) component with optional count, icon, and custom styles.
  This component is versatile and can be used within a list to display content with specific alignment,
  padding, and style.

  ## Examples

  ```elixir
  <.li>LI 1</.li>

  <.li>L2</.li>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :list, default: nil, doc: "Custom CSS class for additional styling"
  attr :count, :integer, default: nil, doc: "Li counter"
  attr :count_separator, :string, default: ". ", doc: "Li counter separator"
  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"

  attr :icon_class, :string,
    default: "list-item-icon",
    doc: "Determines custom class for the icon"

  attr :content_class, :string, default: nil, doc: "Determines custom class for the content"
  attr :padding, :string, default: "none", doc: "Determines padding for items"

  attr :position, :string,
    values: ["start", "end", "center"],
    default: "start",
    doc: "Determines the element position"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  @spec li(map()) :: Phoenix.LiveView.Rendered.t()
  def li(assigns) do
    ~H"""
    <li
      id={@id}
      class={[
        padding_size(@padding),
        @class
      ]}
      {@rest}
    >
      <div class={[
        "flex items-center gap-2 w-full",
        content_position(@position)
      ]}>
        <.icon :if={!is_nil(@icon)} name={@icon} class={@icon_class} />
        <span :if={is_integer(@count)}>{@count}{@count_separator}</span>
        <div class="w-full">
          {render_slot(@inner_block)}
        </div>
      </div>
    </li>
    """
  end

  @doc """
  Renders an unordered list (`ul`) component with customizable styles and attributes.
  You can define the appearance of the list using options for color, variant, size, width, and more.

  It supports a variety of styles including `list-disc` for bulleted lists.

  ## Examples

  ```elixir
  <.ul style="list-disc">
    <li>Default background ul list disc</li>
    <li>Default background ul list disc</li>
    <li>Default background ul list disc</li>
  </.ul>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "natural", doc: "Determines color theme"
  attr :variant, :string, values: @variants, default: "transparent", doc: "Determines the style"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :width, :string, default: "full", doc: "Determines the element width"
  attr :border, :string, values: @sizes, default: "extra_small", doc: "Border size"
  attr :style, :string, default: "list-none", doc: "Determines the element style"
  attr :space, :string, values: @sizes ++ [nil], default: nil, doc: "Space between items"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  def ul(assigns) do
    ~H"""
    <ul
      id={@id}
      class={[
        "[&.list-decimal]:ps-5 [&.list-disc]:ps-5",
        color_variant(@variant, @color),
        border_class(@border, @variant),
        size_class(@size),
        width_class(@width),
        list_space(@space),
        @style,
        @font_weight,
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </ul>
    """
  end

  @doc """
  Renders an ordered list (`ol`) component with customizable styles and attributes.
  The list can be styled with different colors, variants, sizes, widths, and spacing to
  fit various design needs.

  ## Examples

  ```elixir
  <.ol style="list-decimal">
    <li>Ordered list item 1</li>
    <li>Ordered list item 2</li>
    <li>Ordered list item 3</li>
  </.ol>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :color, :string, values: @colors, default: "natural", doc: "Determines color theme"
  attr :variant, :string, values: @variants, default: "transparent", doc: "Determines the style"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :width, :string, default: "full", doc: "Determines the element width"
  attr :border, :string, values: @sizes, default: "extra_small", doc: "Border size"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"
  attr :space, :string, values: @sizes ++ [nil], default: nil, doc: "Space between items"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  def ol(assigns) do
    ~H"""
    <ol
      id={@id}
      class={[
        "list-decimal [&.list-decimal]:ps-5 [&.list-disc]:ps-5",
        color_variant(@variant, @color),
        border_class(@border, @variant),
        size_class(@size),
        width_class(@width),
        list_space(@space),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </ol>
    """
  end

  @doc """
  Renders a list group component with customizable styles, borders, and padding. It can be used to group list items with different variants, colors, and sizes.

  ## Examples

  ```elixir
  <.list_group variant="separated" rounded="extra_small" color="dawn">
    <.li position="end" icon="hero-chat-bubble-left-ellipsis">HBase</.li>
    <.li>SQL</.li>
    <.li>Sqlight</.li>
  </.list_group>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :variant, :string, values: @variants, default: "transparent", doc: "Determines the style"
  attr :color, :string, values: @colors, default: "natural", doc: "Determines color theme"

  attr :size, :string,
    default: "medium",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :width, :string, default: "full", doc: "Determines the element width"
  attr :space, :string, values: @sizes ++ [nil], default: "small", doc: "Space between items"

  attr :rounded, :string,
    values: @sizes ++ ["full", "none"],
    default: "small",
    doc: "Determines the border radius"

  attr :border, :string,
    values: @sizes ++ [nil],
    default: "extra_small",
    doc: "Determines border style"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :padding, :string,
    values: @sizes ++ ["none"],
    default: "none",
    doc: "Determines padding for items"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: true, doc: "Inner block that renders HEEx content"

  def list_group(assigns) do
    ~H"""
    <ul
      id={@id}
      class={[
        "overflow-hidden",
        rounded_size(@rounded),
        variant_space(@space, @variant),
        padding_size(@padding),
        width_class(@width),
        border_class(@border, @variant),
        size_class(@size),
        color_variant(@variant, @color),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </ul>
    """
  end

  defp content_position("start") do
    "justify-start"
  end

  defp content_position("end") do
    "justify-end"
  end

  defp content_position("center") do
    "justify-center"
  end

  defp content_position(_), do: content_position("start")

  defp rounded_size("extra_small"),
    do: "[&:not(.list-items-gap)]:rounded-sm [&.list-items-gap>li]:rounded-sm"

  defp rounded_size("small"), do: "[&:not(.list-items-gap)]:rounded [&.list-items-gap>li]:rounded"

  defp rounded_size("medium"),
    do: "[&:not(.list-items-gap)]:rounded-md [&.list-items-gap>li]:rounded-md"

  defp rounded_size("large"),
    do: "[&:not(.list-items-gap)]:rounded-lg [&.list-items-gap>li]:rounded-lg"

  defp rounded_size("extra_large"),
    do: "[&:not(.list-items-gap)]:rounded-xl [&.list-items-gap>li]:rounded-xl"

  defp rounded_size("full"),
    do: "[&:not(.list-items-gap)]:rounded-full [&.list-items-gap>li]:rounded:full"

  defp rounded_size("none"),
    do: "[&:not(.list-items-gap)]:rounded-none [&.list-items-gap>li]:rounded-none"

  defp variant_space(_, variant) when variant not in ["outline_separated", "bordered_seperated"],
    do: nil

  defp variant_space("extra_small", _), do: "list-items-gap space-y-2"

  defp variant_space("small", _), do: "list-items-gap space-y-3"

  defp variant_space("medium", _), do: "list-items-gap space-y-4"

  defp variant_space("large", _), do: "list-items-gap space-y-5"

  defp variant_space("extra_large", _), do: "list-items-gap space-y-6"

  defp variant_space(params, _) when is_binary(params), do: params
  defp variant_space(_, _), do: nil

  defp list_space("extra_small"), do: "space-y-2"

  defp list_space("small"), do: "space-y-3"

  defp list_space("medium"), do: "space-y-4"

  defp list_space("large"), do: "space-y-5"

  defp list_space("extra_large"), do: "space-y-6"

  defp list_space(params) when is_binary(params), do: params
  defp list_space(_), do: nil

  defp width_class("extra_small"), do: "w-60"
  defp width_class("small"), do: "w-64"
  defp width_class("medium"), do: "w-72"
  defp width_class("large"), do: "w-80"
  defp width_class("extra_large"), do: "w-96"
  defp width_class("full"), do: "w-full"
  defp width_class(params) when is_binary(params), do: params
  defp width_class(_), do: width_class("full")

  defp size_class("extra_small"), do: "text-xs [&_.list-item-icon]:size-4"

  defp size_class("small"), do: "text-sm [&_.list-item-icon]:size-5"

  defp size_class("medium"), do: "text-base [&_.list-item-icon]:size-6"

  defp size_class("large"), do: "text-lg [&_.list-item-icon]:size-7"

  defp size_class("extra_large"), do: "text-xl [&_.list-item-icon]:size-8"

  defp size_class(params) when is_binary(params), do: params

  defp size_class(_), do: size_class("medium")

  defp padding_size("extra_small"), do: "p-1"

  defp padding_size("small"), do: "p-2"

  defp padding_size("medium"), do: "p-3"

  defp padding_size("large"), do: "p-4"

  defp padding_size("extra_large"), do: "p-5"

  defp padding_size("none"), do: "p-0"

  defp padding_size(params) when is_binary(params), do: params

  defp padding_size(_), do: padding_size("none")

  defp border_class(_, variant) when variant in ["default", "shadow", "transparent", "gradient"],
    do: nil

  defp border_class("none", "outline"), do: "border-0 [&>li:not(:last-child)]:border-b-0"

  defp border_class("extra_small", "outline"), do: "border [&>li:not(:last-child)]:border-b"

  defp border_class("small", "outline"), do: "border-2 [&>li:not(:last-child)]:border-b-2"

  defp border_class("medium", "outline"),
    do: "border-[3px] [&>li:not(:last-child)]:border-b-[3px]"

  defp border_class("large", "outline"), do: "border-4 [&>li:not(:last-child)]:border-b-4"

  defp border_class("extra_large", "outline"),
    do: "border-[5px] [&>li:not(:last-child)]:border-b-[5px]"

  defp border_class("none", "bordered"), do: "border-0 [&>li:not(:last-child)]:border-b-0"

  defp border_class("extra_small", "bordered"), do: "border [&>li:not(:last-child)]:border-b"

  defp border_class("small", "bordered"), do: "border-2 [&>li:not(:last-child)]:border-b-2"

  defp border_class("medium", "bordered"),
    do: "border-[3px] [&>li:not(:last-child)]:border-b-[3px]"

  defp border_class("large", "bordered"), do: "border-4 [&>li:not(:last-child)]:border-b-4"

  defp border_class("extra_large", "bordered"),
    do: "border-[5px] [&>li:not(:last-child)]:border-b-[5px]"

  defp border_class("none", "bordered_seperated"), do: "[&>li]:border-0"

  defp border_class("extra_small", "bordered_seperated"), do: "[&>li]:border"

  defp border_class("small", "bordered_seperated"), do: "[&>li]:border-2"

  defp border_class("medium", "bordered_seperated"), do: "[&>li]:border-[3px]"

  defp border_class("large", "bordered_seperated"), do: "[&>li]:border-4"

  defp border_class("extra_large", "bordered_seperated"), do: "[&>li]:border-[5px]"

  defp border_class("none", "outline_seperated"), do: "[&>li]:border-0"

  defp border_class("extra_small", "outline_seperated"), do: "[&>li]:border"

  defp border_class("small", "outline_seperated"), do: "[&>li]:border-2"

  defp border_class("medium", "outline_seperated"), do: "[&>li]:border-[3px]"

  defp border_class("large", "outline_seperated"), do: "[&>li]:border-4"

  defp border_class("extra_large", "outline_seperated"), do: "[&>li]:border-[5px]"

  defp border_class(params, _) when is_binary(params), do: params

  defp border_class(_, _), do: border_class(nil, "transparent")

  defp color_variant("default", "white") do
    ["bg-white text-black"]
  end

  defp color_variant("default", "dark") do
    ["bg-[#282828] text-white"]
  end

  defp color_variant("default", "natural") do
    ["bg-[#4B4B4B] text-white dark:bg-[#DDDDDD] dark:text-black"]
  end

  defp color_variant("default", "primary") do
    ["bg-[#007F8C] text-white dark:bg-[#01B8CA] dark:text-black"]
  end

  defp color_variant("default", "secondary") do
    ["bg-[#266EF1] text-white dark:bg-[#6DAAFB] dark:text-black"]
  end

  defp color_variant("default", "success") do
    ["bg-[#0E8345] text-white dark:bg-[#06C167] dark:text-black"]
  end

  defp color_variant("default", "warning") do
    ["bg-[#CA8D01] text-white dark:bg-[#FDC034] dark:text-black"]
  end

  defp color_variant("default", "danger") do
    ["bg-[#DE1135] text-white dark:bg-[#FC7F79] dark:text-black"]
  end

  defp color_variant("default", "info") do
    ["bg-[#0B84BA] text-white dark:bg-[#3EB7ED] dark:text-black"]
  end

  defp color_variant("default", "misc") do
    ["bg-[#8750C5] text-white dark:bg-[#BA83F9] dark:text-black"]
  end

  defp color_variant("default", "dawn") do
    ["bg-[#A86438] text-white dark:bg-[#DB976B] dark:text-black"]
  end

  defp color_variant("default", "silver") do
    ["bg-[#868686] text-white dark:bg-[#A6A6A6] dark:text-black"]
  end

  defp color_variant("outline", "natural") do
    [
      "text-[#4B4B4B] border-[#4B4B4B] dark:text-[#DDDDDD] dark:border-[#DDDDDD]",
      "[&>li:not(:last-child)]:border-[#4B4B4B] dark:[&>li:not(:last-child)]:border-[#DDDDDD]"
    ]
  end

  defp color_variant("outline", "primary") do
    [
      "text-[#007F8C] border-[#007F8C]  dark:text-[#01B8CA] dark:border-[#01B8CA]",
      "[&>li:not(:last-child)]:border-[#007F8C] dark:[&>li:not(:last-child)]:border-[#01B8CA]"
    ]
  end

  defp color_variant("outline", "secondary") do
    [
      "text-[#266EF1] border-[#266EF1] dark:text-[#6DAAFB] dark:border-[#6DAAFB]",
      "[&>li:not(:last-child)]:border-[#266EF1] dark:[&>li:not(:last-child)]:border-[#6DAAFB]"
    ]
  end

  defp color_variant("outline", "success") do
    [
      "text-[#0E8345] border-[#0E8345] dark:text-[#06C167] dark:border-[#06C167]",
      "[&>li:not(:last-child)]:border-[#0E8345] dark:[&>li:not(:last-child)]:border-[#06C167]"
    ]
  end

  defp color_variant("outline", "warning") do
    [
      "text-[#CA8D01] border-[#CA8D01] dark:text-[#FDC034] dark:border-[#FDC034]",
      "[&>li:not(:last-child)]:border-[#CA8D01] dark:[&>li:not(:last-child)]:border-[#FDC034]"
    ]
  end

  defp color_variant("outline", "danger") do
    [
      "text-[#DE1135] border-[#DE1135] dark:text-[#FC7F79] dark:border-[#FC7F79]",
      "[&>li:not(:last-child)]:border-[#DE1135] dark:[&>li:not(:last-child)]:border-[#FC7F79]"
    ]
  end

  defp color_variant("outline", "info") do
    [
      "text-[#0B84BA] border-[#0B84BA] dark:text-[#3EB7ED] dark:border-[#3EB7ED]",
      "[&>li:not(:last-child)]:border-[#0B84BA] dark:[&>li:not(:last-child)]:border-[#3EB7ED]"
    ]
  end

  defp color_variant("outline", "misc") do
    [
      "text-[#8750C5] border-[#8750C5] dark:text-[#BA83F9] dark:border-[#BA83F9]",
      "[&>li:not(:last-child)]:border-[#8750C5] dark:[&>li:not(:last-child)]:border-[#BA83F9]"
    ]
  end

  defp color_variant("outline", "dawn") do
    [
      "text-[#A86438] border-[#A86438] dark:text-[#DB976B] dark:border-[#DB976B]",
      "[&>li:not(:last-child)]:border-[#A86438] dark:[&>li:not(:last-child)]:border-[#DB976B]"
    ]
  end

  defp color_variant("outline", "silver") do
    [
      "text-[#868686] border-[#868686] dark:text-[#A6A6A6] dark:border-[#A6A6A6]",
      "[&>li:not(:last-child)]:border-[#868686] dark:[&>li:not(:last-child)]:border-[#A6A6A6]"
    ]
  end

  defp color_variant("shadow", "natural") do
    [
      "bg-[#4B4B4B] text-white dark:bg-[#DDDDDD] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "primary") do
    [
      "bg-[#007F8C] text-white dark:bg-[#01B8CA] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(0,149,164,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,149,164,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "secondary") do
    [
      "bg-[#266EF1] text-white dark:bg-[#6DAAFB] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(6,139,238,0.5)] shadow-[0px_10px_15px_-3px_rgba(6,139,238,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "success") do
    [
      "bg-[#0E8345] text-white hover:bg-[#166C3B] dark:bg-[#06C167] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(0,154,81,0.5)] shadow-[0px_10px_15px_-3px_rgba(0,154,81,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "warning") do
    [
      "bg-[#CA8D01] text-white dark:bg-[#FDC034] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(252,176,1,0.5)] shadow-[0px_10px_15px_-3px_rgba(252,176,1,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "danger") do
    [
      "bg-[#DE1135] text-white dark:bg-[#FC7F79] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(248,52,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(248,52,70,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "info") do
    [
      "bg-[#0B84BA] text-white dark:bg-[#3EB7ED] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(14,165,233,0.5)] shadow-[0px_10px_15px_-3px_rgba(14,165,233,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "misc") do
    [
      "bg-[#8750C5] text-white dark:bg-[#BA83F9] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(169,100,247,0.5)] shadow-[0px_10px_15px_-3px_rgba(169,100,247,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "dawn") do
    [
      "bg-[#A86438] text-white dark:bg-[#DB976B] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(210,125,70,0.5)] shadow-[0px_10px_15px_-3px_rgba(210,125,70,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("shadow", "silver") do
    [
      "bg-[#868686] text-white dark:bg-[#A6A6A6] dark:text-black",
      "shadow-[0px_4px_6px_-4px_rgba(134,134,134,0.5)] shadow-[0px_10px_15px_-3px_rgba(134,134,134,0.5)] dark:shadow-none"
    ]
  end

  defp color_variant("bordered", "white") do
    [
      "bg-white text-black border-[#DDDDDD]",
      "[&>li:not(:last-child)]:border-[#DDDDDD]"
    ]
  end

  defp color_variant("bordered", "dark") do
    [
      "bg-[#282828] text-white border-[#727272]",
      "[&>li:not(:last-child)]:border-[#727272]"
    ]
  end

  defp color_variant("bordered", "natural") do
    [
      "text-[#282828] border-[#282828] bg-[#F3F3F3]",
      "dark:text-[#E8E8E8] dark:border-[#E8E8E8] dark:bg-[#4B4B4B]",
      "[&>li:not(:last-child)]:border-[#282828] dark:[&>li:not(:last-child)]:border-[#E8E8E8]"
    ]
  end

  defp color_variant("bordered", "primary") do
    [
      "text-[#016974] border-[#016974] bg-[#E2F8FB]",
      "dark:text-[#77D5E3] dark:border-[#77D5E3] dark:bg-[#002D33]",
      "[&>li:not(:last-child)]:border-[#016974] dark:[&>li:not(:last-child)]:border-[#77D5E3]"
    ]
  end

  defp color_variant("bordered", "secondary") do
    [
      "text-[#175BCC] border-[#175BCC] bg-[#EFF4FE]",
      "dark:text-[#A9C9FF] dark:border-[#A9C9FF] dark:bg-[#002661]",
      "[&>li:not(:last-child)]:border-[#175BCC] dark:[&>li:not(:last-child)]:border-[#A9C9FF]"
    ]
  end

  defp color_variant("bordered", "success") do
    [
      "text-[#166C3B] border-[#166C3B] bg-[#EAF6ED]",
      "dark:text-[#7FD99A] dark:border-[#7FD99A] dark:bg-[#002F14]",
      "[&>li:not(:last-child)]:border-[#166C3B] dark:[&>li:not(:last-child)]:border-[#7FD99A]"
    ]
  end

  defp color_variant("bordered", "warning") do
    [
      "text-[#976A01] border-[#976A01] bg-[#FFF7E6]",
      "dark:text-[#FDD067] dark:border-[#FDD067] dark:bg-[#322300]",
      "[&>li:not(:last-child)]:border-[#976A01] dark:[&>li:not(:last-child)]:border-[#FDD067]"
    ]
  end

  defp color_variant("bordered", "danger") do
    [
      "text-[#BB032A] border-[#BB032A] bg-[#FFF0EE]",
      "dark:text-[#FFB2AB] dark:border-[#FFB2AB] dark:bg-[#520810]",
      "[&>li:not(:last-child)]:border-[#BB032A] dark:[&>li:not(:last-child)]:border-[#FFB2AB]"
    ]
  end

  defp color_variant("bordered", "info") do
    [
      "text-[#0B84BA] border-[#0B84BA] bg-[#E7F6FD]",
      "dark:text-[#6EC9F2] dark:border-[#6EC9F2] dark:bg-[#03212F]",
      "[&>li:not(:last-child)]:border-[#0B84BA] dark:[&>li:not(:last-child)]:border-[#6EC9F2]"
    ]
  end

  defp color_variant("bordered", "misc") do
    [
      "text-[#653C94] border-[#653C94] bg-[#F6F0FE]",
      "dark:text-[#CBA2FA] dark:border-[#CBA2FA] dark:bg-[#221431]",
      "[&>li:not(:last-child)]:border-[#653C94] dark:[&>li:not(:last-child)]:border-[#CBA2FA]"
    ]
  end

  defp color_variant("bordered", "dawn") do
    [
      "text-[#7E4B2A] border-[#7E4B2A] bg-[#FBF2ED]",
      "dark:text-[#E4B190] dark:border-[#E4B190] dark:bg-[#2A190E]",
      "[&>li:not(:last-child)]:border-[#7E4B2A] dark:[&>li:not(:last-child)]:border-[#E4B190]"
    ]
  end

  defp color_variant("bordered", "silver") do
    [
      "text-[#727272] border-[#727272] bg-[#F3F3F3]",
      "dark:text-[#BBBBBB] dark:border-[#BBBBBB] dark:bg-[#4B4B4B]",
      "[&>li:not(:last-child)]:border-[#727272] dark:[&>li:not(:last-child)]:border-[#BBBBBB]"
    ]
  end

  defp color_variant("transparent", "natural") do
    [
      "text-[#4B4B4B] dark:text-[#DDDDDD]"
    ]
  end

  defp color_variant("transparent", "primary") do
    [
      "text-[#007F8C] dark:text-[#01B8CA]"
    ]
  end

  defp color_variant("transparent", "secondary") do
    [
      "text-[#266EF1] dark:text-[#6DAAFB]"
    ]
  end

  defp color_variant("transparent", "success") do
    [
      "text-[#0E8345] dark:text-[#06C167]"
    ]
  end

  defp color_variant("transparent", "warning") do
    [
      "text-[#CA8D01] dark:text-[#FDC034]"
    ]
  end

  defp color_variant("transparent", "danger") do
    [
      "text-[#DE1135] dark:text-[#FC7F79]"
    ]
  end

  defp color_variant("transparent", "info") do
    [
      "text-[#0B84BA] dark:text-[#3EB7ED]"
    ]
  end

  defp color_variant("transparent", "misc") do
    [
      "text-[#8750C5] dark:text-[#BA83F9]"
    ]
  end

  defp color_variant("transparent", "dawn") do
    [
      "text-[#A86438] dark:text-[#DB976B]"
    ]
  end

  defp color_variant("transparent", "silver") do
    [
      "text-[#868686] dark:text-[#A6A6A6]"
    ]
  end

  defp color_variant("gradient", "natural") do
    [
      "bg-gradient-to-br from-[#282828] to-[#727272] text-white",
      "dark:from-[#A6A6A6] dark:to-[#FFFFFF] dark:text-black"
    ]
  end

  defp color_variant("gradient", "primary") do
    [
      "bg-gradient-to-br from-[#016974] to-[#01B8CA] text-white",
      "dark:from-[#01B8CA] dark:to-[#B0E7EF] dark:text-black"
    ]
  end

  defp color_variant("gradient", "secondary") do
    [
      "bg-gradient-to-br from-[#175BCC] to-[#6DAAFB] text-white",
      "dark:from-[#6DAAFB] dark:to-[#CDDEFF] dark:text-black"
    ]
  end

  defp color_variant("gradient", "success") do
    [
      "bg-gradient-to-br from-[#166C3B] to-[#06C167] text-white",
      "dark:from-[#06C167] dark:to-[#B1EAC2] dark:text-black"
    ]
  end

  defp color_variant("gradient", "warning") do
    [
      "bg-gradient-to-br from-[#976A01] to-[#FDC034] text-white",
      "dark:from-[#FDC034] dark:to-[#FEDF99] dark:text-black"
    ]
  end

  defp color_variant("gradient", "danger") do
    [
      "bg-gradient-to-br from-[#BB032A] to-[#FC7F79] text-white",
      "dark:from-[#FC7F79] dark:to-[#FFD2CD] dark:text-black"
    ]
  end

  defp color_variant("gradient", "info") do
    [
      "bg-gradient-to-br from-[#08638C] to-[#3EB7ED] text-white",
      "dark:from-[#3EB7ED] dark:to-[#9FDBF6] dark:text-black"
    ]
  end

  defp color_variant("gradient", "misc") do
    [
      "bg-gradient-to-br from-[#653C94] to-[#BA83F9] text-white",
      "dark:from-[#BA83F9] dark:to-[#DDC1FC] dark:text-black"
    ]
  end

  defp color_variant("gradient", "dawn") do
    [
      "bg-gradient-to-br from-[#7E4B2A] to-[#DB976B] text-white",
      "dark:from-[#DB976B] dark:to-[#EDCBB5] dark:text-black"
    ]
  end

  defp color_variant("gradient", "silver") do
    [
      "bg-gradient-to-br from-[#5E5E5E] to-[#A6A6A6] text-white",
      "dark:from-[#868686] dark:to-[#BBBBBB] dark:text-black"
    ]
  end

  defp color_variant("bordered_seperated", "natural") do
    [
      "[&>li]:text-[#282828] [&>li]:border-[#282828] [&>li]:bg-[#F3F3F3]",
      "dark:[&>li]:text-[#E8E8E8] dark:[&>li]:border-[#E8E8E8] dark:[&>li]:bg-[#4B4B4B]"
    ]
  end

  defp color_variant("bordered_seperated", "primary") do
    [
      "[&>li]:text-[#016974] [&>li]:border-[#016974] [&>li]:bg-[#E2F8FB]",
      "dark:[&>li]:text-[#77D5E3] dark:[&>li]:border-[#77D5E3] dark:[&>li]:bg-[#002D33]"
    ]
  end

  defp color_variant("bordered_seperated", "secondary") do
    [
      "[&>li]:text-[#175BCC] [&>li]:border-[#175BCC] [&>li]:bg-[#EFF4FE]",
      "dark:[&>li]:text-[#A9C9FF] dark:[&>li]:border-[#A9C9FF] dark:[&>li]:bg-[#002661]"
    ]
  end

  defp color_variant("bordered_seperated", "success") do
    [
      "[&>li]:text-[#166C3B] [&>li]:border-[#166C3B] [&>li]:bg-[#EAF6ED]",
      "dark:[&>li]:text-[#7FD99A] dark:[&>li]:border-[#7FD99A] dark:[&>li]:bg-[#002F14]"
    ]
  end

  defp color_variant("bordered_seperated", "warning") do
    [
      "[&>li]:text-[#976A01] [&>li]:border-[#976A01] [&>li]:bg-[#FFF7E6]",
      "dark:[&>li]:text-[#FDD067] dark:[&>li]:border-[#FDD067] dark:[&>li]:bg-[#322300]"
    ]
  end

  defp color_variant("bordered_seperated", "danger") do
    [
      "[&>li]:text-[#BB032A] [&>li]:border-[#BB032A] [&>li]:bg-[#FFF0EE]",
      "dark:[&>li]:text-[#FFB2AB] dark:[&>li]:border-[#FFB2AB] dark:[&>li]:bg-[#520810]"
    ]
  end

  defp color_variant("bordered_seperated", "info") do
    [
      "[&>li]:text-[#0B84BA] [&>li]:border-[#0B84BA] [&>li]:bg-[#E7F6FD]",
      "dark:[&>li]:text-[#6EC9F2] dark:[&>li]:border-[#6EC9F2] dark:[&>li]:bg-[#03212F]"
    ]
  end

  defp color_variant("bordered_seperated", "misc") do
    [
      "[&>li]:text-[#653C94] [&>li]:border-[#653C94] [&>li]:bg-[#F6F0FE]",
      "dark:[&>li]:text-[#CBA2FA] dark:[&>li]:border-[#CBA2FA] dark:[&>li]:bg-[#221431]"
    ]
  end

  defp color_variant("bordered_seperated", "dawn") do
    [
      "[&>li]:text-[#7E4B2A] [&>li]:border-[#7E4B2A] [&>li]:bg-[#FBF2ED]",
      "dark:[&>li]:text-[#E4B190] dark:[&>li]:border-[#E4B190] dark:[&>li]:bg-[#2A190E]"
    ]
  end

  defp color_variant("bordered_seperated", "silver") do
    [
      "[&>li]:text-[#727272] [&>li]:border-[#727272] [&>li]:bg-[#F3F3F3]",
      "dark:[&>li]:text-[#BBBBBB] dark:[&>li]:border-[#BBBBBB] dark:[&>li]:bg-[#4B4B4B]"
    ]
  end

  defp color_variant("outline_separated", "natural") do
    [
      "[&>li]:text-[#4B4B4B] [&>li]:border-[#4B4B4B] dark:[&>li]:text-[#DDDDDD] dark:[&>li]:border-[#DDDDDD]"
    ]
  end

  defp color_variant("outline_separated", "primary") do
    [
      "[&>li]:text-[#007F8C] [&>li]:border-[#007F8C]  dark:[&>li]:text-[#01B8CA] dark:[&>li]:border-[#01B8CA]"
    ]
  end

  defp color_variant("outline_separated", "secondary") do
    [
      "[&>li]:text-[#266EF1] [&>li]:border-[#266EF1] dark:[&>li]:text-[#6DAAFB] dark:[&>li]:border-[#6DAAFB]"
    ]
  end

  defp color_variant("outline_separated", "success") do
    [
      "[&>li]:text-[#0E8345] [&>li]:border-[#0E8345] dark:[&>li]:text-[#06C167] dark:[&>li]:border-[#06C167]"
    ]
  end

  defp color_variant("outline_separated", "warning") do
    [
      "[&>li]:text-[#CA8D01] [&>li]:border-[#CA8D01] dark:[&>li]:text-[#FDC034] dark:[&>li]:border-[#FDC034]"
    ]
  end

  defp color_variant("outline_separated", "danger") do
    [
      "[&>li]:text-[#DE1135] [&>li]:border-[#DE1135] dark:[&>li]:text-[#FC7F79] dark:[&>li]:border-[#FC7F79]"
    ]
  end

  defp color_variant("outline_separated", "info") do
    [
      "[&>li]:text-[#0B84BA] [&>li]:border-[#0B84BA] dark:[&>li]:text-[#3EB7ED] dark:[&>li]:border-[#3EB7ED]"
    ]
  end

  defp color_variant("outline_separated", "misc") do
    [
      "[&>li]:text-[#8750C5] [&>li]:border-[#8750C5] dark:[&>li]:text-[#BA83F9] dark:[&>li]:border-[#BA83F9]"
    ]
  end

  defp color_variant("outline_separated", "dawn") do
    [
      "[&>li]:text-[#A86438] [&>li]:border-[#A86438] dark:[&>li]:text-[#DB976B] dark:[&>li]:border-[#DB976B]"
    ]
  end

  defp color_variant("outline_separated", "silver") do
    [
      "[&>li]:text-[#868686] [&>li]:border-[#868686] dark:[&>li]:text-[#A6A6A6] dark:[&>li]:border-[#A6A6A6]"
    ]
  end

  defp color_variant(params, _) when is_binary(params), do: params

  defp color_variant(_, _), do: color_variant("transparent", "natural")

  attr :name, :string, required: true, doc: "Specifies the name of the element"
  attr :class, :any, default: nil, doc: "Custom CSS class for additional styling"

  defp icon(%{name: "hero-" <> _, class: class} = assigns) when is_list(class) do
    ~H"""
    <span class={[@name] ++ @class} />
    """
  end

  defp icon(%{name: "hero-" <> _} = assigns) do
    ~H"""
    <span class={[@name, @class]} />
    """
  end
end
