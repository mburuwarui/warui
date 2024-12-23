defmodule WaruiWeb.Components.Stepper do
  @moduledoc """
  The `WaruiWeb.Components.Stepper` module provides a flexible and interactive stepper component
  for Phoenix LiveView applications. It supports both horizontal and vertical layouts,
  making it ideal for displaying multi-step processes, such as onboarding, forms, or any
  workflow that requires users to follow a sequence of steps.

  This module allows extensive customization options, including size, color themes, border styles,
  and spacing between steps. Each step can display icons, titles, descriptions, and custom content.
  The component also offers various step states like `current`, `loading`, `completed`, and `canceled`,
  enabling a visual indication of the user's progress.

  The `WaruiWeb.Components.Stepper` enhances user experience by providing a clear and concise representation
  of step-by-step workflows, ensuring users can easily track their position and progress within the application.
  """

  use Phoenix.Component

  @colors [
    "natural",
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

  @doc """
  Renders a customizable `stepper` component that visually represents a multi-step process.
  This component can be configured to display either horizontally or vertically, with various
  styling options like color, size, and spacing.

  ## Examples

  ```elixir
  <.stepper color="info" size="extra_large">
    <.stepper_section step="current" title="First step" description="Create an account" />
    <.stepper_section title="Second Step" description="Verify email" />
    <.stepper_section title="Third Step" description="Get full access" />
  </.stepper>
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :size, :string,
    default: "small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :margin, :string, default: "medium", doc: "Determines the element margin"
  attr :color, :string, values: @colors, default: "natural", doc: "Determines color theme"
  attr :space, :string, default: nil, doc: "Space between items"
  attr :border, :string, default: "extra_small", doc: "Determines border style"

  attr :font_weight, :string,
    default: "font-normal",
    doc: "Determines custom class for the font weight"

  attr :max_width, :string, default: nil, doc: "Determines the style of element max width"
  attr :seperator_size, :string, default: "extra_small", doc: "Determines the seperator size"
  attr :vertical, :boolean, default: false, doc: "Determines whether element is vertical"
  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :rest, :global,
    doc:
      "Global attributes can define defaults which are merged with attributes provided by the caller"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  @spec stepper(map()) :: Phoenix.LiveView.Rendered.t()
  def stepper(%{vertical: true} = assigns) do
    ~H"""
    <div class={[
      "vertical-stepper relative flex flex-col",
      "[&_.vertical-step:last-child_.stepper-seperator]:hidden",
      step_visibility(),
      border_class(@border),
      space_class(@space),
      size_class(@size),
      color_class(@color),
      @font_weight,
      @class
    ]}>
      {render_slot(@inner_block)}
    </div>
    """
  end

  def stepper(assigns) do
    ~H"""
    <div
      id={@id}
      class={[
        "flex flex-row flex-start items-center flex-wrap gap-y-5",
        "[&_.stepper-seperator:last-child]:hidden",
        step_visibility(),
        size_class(@size),
        color_class(@color),
        border_class(@border),
        wrapper_width(@max_width),
        seperator_margin(@margin),
        seperator_size(@seperator_size),
        @font_weight,
        @class
      ]}
      {@rest}
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  Renders a `stepper_section` within the stepper component, representing each individual step of
  a multi-step process.

  This section can display information such as the step number, title, description, and an icon.
  It can also be customized to show different states, such as current, loading, completed, or canceled.

  ## Examples

  Horizontal Step Section:

  ```elixir
  <.stepper_section step="current" title="First step" description="Create an account" />
  <.stepper_section title="Second Step" description="Verify email" />
  <.stepper_section title="Third Step" description="Get full access" />
  ```
  """
  @doc type: :component
  attr :id, :string,
    default: nil,
    doc: "A unique identifier is used to manage state and interaction"

  attr :class, :string, default: nil, doc: "Custom CSS class for additional styling"

  attr :size, :string,
    default: "small",
    doc:
      "Determines the overall size of the elements, including padding, font size, and other items"

  attr :step, :string,
    values: ["none", "current", "loading", "compeleted", "canceled"],
    default: "none"

  attr :icon, :string, default: nil, doc: "Icon displayed alongside of an item"
  attr :color, :string, default: "white"
  attr :title, :string, default: nil, doc: "Specifies the title of the element"
  attr :description, :string, default: nil, doc: "Determines a short description"
  attr :step_number, :integer, default: 1
  attr :vertical, :boolean, default: false, doc: "Determines whether element is vertical"

  attr :clickable, :boolean,
    default: true,
    doc: "Determines if the element can be activated on click"

  attr :reverse, :boolean, default: false, doc: "Switches the order of the element and label"
  attr :border, :string, default: "none", doc: "Determines border style"

  slot :inner_block, required: false, doc: "Inner block that renders HEEx content"

  def stepper_section(%{vertical: true} = assigns) do
    ~H"""
    <button
      id={@id}
      class={[
        "stepper-#{@step}-step",
        "vertical-step overflow-hidden flex flex-row text-start gap-4",
        @class
      ]}
      disabled={!@clickable}
    >
      <span class="block relative">
        <span class="stepper-seperator block h-screen absolute start-1/2"></span>
        <span
          :if={@icon}
          class={[
            "stepper-step relative border-2 rounded-full flex justify-center items-center shrink-0",
            "transition-all ease-in-out duration-400 delay-100"
          ]}
        >
          <.icon name={@icon} class="step-symbol stepper-icon" />
          <.icon
            name="hero-check-solid"
            class={[
              "stepper-icon stepper-compeleted-icon",
              "transition-all ease-in-out duration-400 delay-100"
            ]}
          />
        </span>

        <span
          :if={!@icon}
          class={[
            "stepper-step relative border-2 rounded-full flex justify-center items-center shrink-0",
            "transition-all ease-in-out duration-400 delay-100"
          ]}
        >
          <span class="step-symbol">{@step_number}</span>
          <.icon
            name="hero-check-solid"
            class={[
              "stepper-icon stepper-compeleted-icon",
              "transition-all ease-in-out duration-400 delay-100"
            ]}
          />
        </span>
      </span>

      <span class="block text-nowrap">
        <span :if={@title} class="block font-bold">
          {@title}
        </span>

        <span :if={@description} class="block text-xs">
          {@description}
        </span>
        {render_slot(@inner_block)}
      </span>
    </button>
    """
  end

  def stepper_section(assigns) do
    ~H"""
    <button
      id={@id}
      class={[
        "stepper-#{@step}-step",
        "text-start flex flex-nowrap justify-center items-center shrink-0",
        @reverse && "flex-row-reverse text-end",
        @class
      ]}
      disabled={!@clickable}
    >
      <span
        :if={@icon}
        class={[
          "stepper-step border-2 rounded-full flex justify-center items-center shrink-0",
          "transition-all ease-in-out duration-400 delay-100"
        ]}
      >
        <.icon name={@icon} class="step-symbol stepper-icon" />
        <.icon
          name="hero-check-solid"
          class={[
            "stepper-icon stepper-compeleted-icon",
            "transition-all ease-in-out duration-400 delay-100"
          ]}
        />
      </span>

      <span
        :if={!@icon}
        class={[
          "stepper-step border-2 rounded-full flex justify-center items-center shrink-0",
          "transition-all ease-in-out duration-400 delay-100"
        ]}
      >
        <span class="step-symbol">{@step_number}</span>
        <.icon
          name="hero-check-solid"
          class={[
            "stepper-icon stepper-compeleted-icon",
            "transition-all ease-in-out duration-400 delay-100"
          ]}
        />
      </span>

      <span class={[
        "block text-nowrap",
        if(@reverse, do: "[&>span]:me-4", else: "[&>span]:ms-4")
      ]}>
        <span :if={@title} class="block font-bold">
          {@title}
        </span>

        <span :if={@description} class="block text-xs">
          {@description}
        </span>

        <span :if={@description} class="block">
          {render_slot(@inner_block)}
        </span>
      </span>
    </button>

    <div class="stepper-seperator w-full flex-1"></div>
    """
  end

  defp step_visibility() do
    [
      "[&_.stepper-compeleted-icon]:hidden",
      "[&_.stepper-compeleted-icon]:invisible",
      "[&_.stepper-compeleted-icon]:opacity-0",
      "[&_.stepper-compeleted-step_.stepper-compeleted-icon]:block",
      "[&_.stepper-compeleted-step_.stepper-compeleted-icon]:visible",
      "[&_.stepper-compeleted-step_.stepper-compeleted-icon]:opacity-100",
      "[&_.stepper-compeleted-step_.step-symbol]:hidden",
      "[&_.stepper-compeleted-step_.step-symbol]:invisible",
      "[&_.stepper-compeleted-step_.step-symbol]:opacity-0"
    ]
  end

  defp seperator_margin("none") do
    [
      "[&_.stepper-seperator]:mx-0"
    ]
  end

  defp seperator_margin("extra_small") do
    [
      "[&_.stepper-seperator]:mx-1",
      "xl:[&_.stepper-seperator]:mx-3"
    ]
  end

  defp seperator_margin("small") do
    [
      "[&_.stepper-seperator]:mx-2",
      "xl:[&_.stepper-seperator]:mx-4"
    ]
  end

  defp seperator_margin("medium") do
    [
      "[&_.stepper-seperator]:mx-2",
      "xl:[&_.stepper-seperator]:mx-6"
    ]
  end

  defp seperator_margin("large") do
    [
      "[&_.stepper-seperator]:mx-3",
      "xl:[&_.stepper-seperator]:mx-8"
    ]
  end

  defp seperator_margin("extra_large") do
    [
      "[&_.stepper-seperator]:mx-3",
      "xl:[&_.stepper-seperator]:mx-10"
    ]
  end

  defp seperator_margin(params) when is_binary(params), do: params
  defp seperator_margin(_), do: seperator_margin("medium")

  defp border_class("extra_small") do
    [
      "[&.vertical-stepper_.stepper-seperator]:border-s",
      "[&:not(.vertical-stepper)_.stepper-seperator]:border-t"
    ]
  end

  defp border_class("small") do
    [
      "[&.vertical-stepper_.stepper-seperator]:border-s-2",
      "[&:not(.vertical-stepper)_.stepper-seperator]:border-t-2"
    ]
  end

  defp border_class("medium") do
    [
      "[&.vertical-stepper_.stepper-seperator]:border-s-[3px]",
      "[&:not(.vertical-stepper)_.stepper-seperator]:border-t-[3px]"
    ]
  end

  defp border_class("large") do
    [
      "[&.vertical-stepper_.stepper-seperator]:border-s-4",
      "[&:not(.vertical-stepper)_.stepper-seperator]:border-t-4"
    ]
  end

  defp border_class("extra_large") do
    [
      "[&.vertical-stepper_.stepper-seperator]:border-s-[5px]",
      "[&:not(.vertical-stepper)_.stepper-seperator]:border-t-[5px]"
    ]
  end

  defp border_class(params) when is_binary(params), do: params
  defp border_class(_), do: border_class("extra_small")

  defp space_class("extra_small"), do: "space-y-1"

  defp space_class("small"), do: "space-y-2"

  defp space_class("medium"), do: "space-y-3"

  defp space_class("large"), do: "space-y-4"

  defp space_class("extra_large"), do: "space-y-5"

  defp space_class(params) when is_binary(params), do: params
  defp space_class(_), do: nil

  defp wrapper_width("extra_small"), do: "max-w-1/4"
  defp wrapper_width("small"), do: "max-w-2/4"
  defp wrapper_width("medium"), do: "max-w-3/4"
  defp wrapper_width("large"), do: "max-w-11/12"
  defp wrapper_width("extra_large"), do: "max-"
  defp wrapper_width(params) when is_binary(params), do: params
  defp wrapper_width(_), do: nil

  defp size_class("extra_small") do
    [
      "text-xs [&_.stepper-step]:size-7 [&_.stepper-icon]:size-4",
      "[&_.vertical-step:not(:last-child)]:min-h-10"
    ]
  end

  defp size_class("small") do
    [
      "text-sm [&_.stepper-step]:size-8 [&_.stepper-icon]:size-5",
      "[&_.vertical-step:not(:last-child)]:min-h-12"
    ]
  end

  defp size_class("medium") do
    [
      "text-base [&_.stepper-step]:size-9 [&_.stepper-icon]:size-6",
      "[&_.vertical-step:not(:last-child)]:min-h-14"
    ]
  end

  defp size_class("large") do
    [
      "text-lg [&_.stepper-step]:size-10 [&_.stepper-icon]:size-7",
      "[&_.vertical-step:not(:last-child)]:min-h-16"
    ]
  end

  defp size_class("extra_large") do
    [
      "text-xl [&_.stepper-step]:size-11 [&_.stepper-icon]:size-8",
      "[&_.vertical-step:not(:last-child)]:min-h-20"
    ]
  end

  defp size_class(params) when is_binary(params), do: params

  defp size_class(_), do: size_class("medium")

  defp seperator_size("extra_small"), do: "[&_.stepper-seperator]:h-px"
  defp seperator_size("small"), do: "[&_.stepper-seperator]:h-0.5"
  defp seperator_size("medium"), do: "[&_.stepper-seperator]:h-1"
  defp seperator_size("large"), do: "[&_.stepper-seperator]:h-1.5"
  defp seperator_size("extra_large"), do: "[&_.stepper-seperator]:h-2"
  defp seperator_size(params) when is_binary(params), do: params
  defp seperator_size(_), do: seperator_size("extra_small")

  # colors
  # stepper-loading-step, stepper-current-step, stepper-compeleted-step, stepper-canceled-step

  defp color_class("natural") do
    [
      "[&_.stepper-step]:bg-[#F3F3F3] [&_.stepper-step]:text-[#282828]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#282828]",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-[#E8E8E8] [&_.stepper-compeleted-step_.stepper-step]:border-black",
      "dark:[&_.stepper-step]:bg-[#4B4B4B] dark:[&_.stepper-step]:text-[#E8E8E8]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#E8E8E8]",
      "dark:[&_.stepper-compeleted-step_.stepper-step]:bg-[#5E5E5E] dark:[&_.stepper-compeleted-step_.stepper-step]:border-white",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#282828] dark:[&_.stepper-seperator]:border-[#E8E8E8]",
      "[&_.stepper-compeleted-step+.stepper-seperator]:border-black dark:[&_.stepper-compeleted-step+.stepper-seperator]:border-white",
      "[&.vertical-stepper_.stepper-compeleted-step_.stepper-seperator]:border-black",
      "dark:[&.vertical-stepper_.stepper-compeleted-step_.stepper-seperator]:border-white"
    ]
  end

  defp color_class("primary") do
    [
      "[&_.stepper-step]:bg-[#E2F8FB] [&_.stepper-step]:text-[#016974]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#016974]",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-[#CDEEF3] [&_.stepper-compeleted-step_.stepper-step]:border-[#1A535A]",
      "dark:[&_.stepper-step]:bg-[#002D33] dark:[&_.stepper-step]:text-[#77D5E3]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#77D5E3]",
      "dark:[&_.stepper-compeleted-step_.stepper-step]:bg-[#1A535A] dark:[&_.stepper-compeleted-step_.stepper-step]:border-[#B0E7EF]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#016974] dark:[&_.stepper-seperator]:border-[#77D5E3]",
      "[&_.stepper-compeleted-step+.stepper-seperator]:border-[#1A535A] dark:[&_.stepper-compeleted-step+.stepper-seperator]:border-[#B0E7EF]",
      "[&.vertical-stepper_.stepper-compeleted-step_.stepper-seperator]:border-[#1A535A]",
      "dark:[&.vertical-stepper_.stepper-compeleted-step_.stepper-seperator]:border-[#B0E7EF]"
    ]
  end

  defp color_class("secondary") do
    [
      "[&_.stepper-step]:bg-[#EFF4FE] [&_.stepper-step]:text-[#175BCC]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#175BCC]",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-[#DEE9FE] [&_.stepper-compeleted-step_.stepper-step]:border-[#1948A3]",
      "dark:[&_.stepper-step]:bg-[#002661] dark:[&_.stepper-step]:text-[#A9C9FF]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#A9C9FF]",
      "dark:[&_.stepper-compeleted-step_.stepper-step]:bg-[#1948A3] dark:[&_.stepper-compeleted-step_.stepper-step]:border-[#CDDEFF]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#175BCC] dark:[&_.stepper-seperator]:border-[#A9C9FF]",
      "[&_.stepper-compeleted-step+.stepper-seperator]:border-[#1948A3] dark:[&_.stepper-compeleted-step+.stepper-seperator]:border-[#CDDEFF]",
      "[&.vertical-stepper_.stepper-compeleted-step_.stepper-seperator]:border-[#1948A3]",
      "dark:[&.vertical-stepper_.stepper-compeleted-step_.stepper-seperator]:border-[#CDDEFF]"
    ]
  end

  defp color_class("success") do
    [
      "[&_.stepper-step]:bg-[#EAF6ED] [&_.stepper-step]:text-[#166C3B]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#166C3B]",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-[#D3EFDA] [&_.stepper-compeleted-step_.stepper-step]:border-[#0D572D]",
      "dark:[&_.stepper-step]:bg-[#002F14] dark:[&_.stepper-step]:text-[#7FD99A]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#7FD99A]",
      "dark:[&_.stepper-compeleted-step_.stepper-step]:bg-[#0D572D] dark:[&_.stepper-compeleted-step_.stepper-step]:border-[#B1EAC2]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#166C3B] dark:[&_.stepper-seperator]:border-[#7FD99A]",
      "[&_.stepper-compeleted-step+.stepper-seperator]:border-[#0D572D] dark:[&_.stepper-compeleted-step+.stepper-seperator]:border-[#B1EAC2]",
      "[&.vertical-stepper_.stepper-compeleted-step_.stepper-seperator]:border-[#0D572D]",
      "dark:[&.vertical-stepper_.stepper-compeleted-step_.stepper-seperator]:border-[#B1EAC2]"
    ]
  end

  defp color_class("warning") do
    [
      "[&_.stepper-step]:bg-[#FFF7E6] [&_.stepper-step]:text-[#976A01]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#976A01]",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-[#FEEFCC] [&_.stepper-compeleted-step_.stepper-step]:border-[#654600]",
      "dark:[&_.stepper-step]:bg-[#322300] dark:[&_.stepper-step]:text-[#FDD067]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#FDD067]",
      "dark:[&_.stepper-compeleted-step_.stepper-step]:bg-[#654600] dark:[&_.stepper-compeleted-step_.stepper-step]:border-[#FEDF99]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#976A01] dark:[&_.stepper-seperator]:border-[#FDD067]",
      "[&_.stepper-compeleted-step+.stepper-seperator]:border-[#654600] dark:[&_.stepper-compeleted-step+.stepper-seperator]:border-[#FEDF99]",
      "[&.vertical-stepper_.stepper-compeleted-step_.stepper-seperator]:border-[#654600]",
      "dark:[&.vertical-stepper_.stepper-compeleted-step_.stepper-seperator]:border-[#FEDF99]"
    ]
  end

  defp color_class("danger") do
    [
      "[&_.stepper-step]:bg-[#FFF0EE] [&_.stepper-step]:text-[#BB032A]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#BB032A]",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-[#FFE1DE] [&_.stepper-compeleted-step_.stepper-step]:border-[#950F22]",
      "dark:[&_.stepper-step]:bg-[#520810] dark:[&_.stepper-step]:text-[#FFB2AB]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#FFB2AB]",
      "dark:[&_.stepper-compeleted-step_.stepper-step]:bg-[#950F22] dark:[&_.stepper-compeleted-step_.stepper-step]:border-[#FFD2CD]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#BB032A] dark:[&_.stepper-seperator]:border-[#FFB2AB]",
      "[&_.stepper-compeleted-step+.stepper-seperator]:border-[#950F22] dark:[&_.stepper-compeleted-step+.stepper-seperator]:border-[#FFD2CD]",
      "[&.vertical-stepper_.stepper-compeleted-step_.stepper-seperator]:border-[#950F22]",
      "dark:[&.vertical-stepper_.stepper-compeleted-step_.stepper-seperator]:border-[#FFD2CD]"
    ]
  end

  defp color_class("info") do
    [
      "[&_.stepper-step]:bg-[#E7F6FD] [&_.stepper-step]:text-[#08638C]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#08638C]",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-[#CFEDFB] [&_.stepper-compeleted-step_.stepper-step]:border-[#06425D]",
      "dark:[&_.stepper-step]:bg-[#03212F] dark:[&_.stepper-step]:text-[#6EC9F2]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#6EC9F2]",
      "dark:[&_.stepper-compeleted-step_.stepper-step]:bg-[#06425D] dark:[&_.stepper-compeleted-step_.stepper-step]:border-[#9FDBF6]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#08638C] dark:[&_.stepper-seperator]:border-[#6EC9F2]",
      "[&_.stepper-compeleted-step+.stepper-seperator]:border-[#06425D] dark:[&_.stepper-compeleted-step+.stepper-seperator]:border-[#9FDBF6]",
      "[&.vertical-stepper_.stepper-compeleted-step_.stepper-seperator]:border-[#06425D]",
      "dark:[&.vertical-stepper_.stepper-compeleted-step_.stepper-seperator]:border-[#9FDBF6]"
    ]
  end

  defp color_class("misc") do
    [
      "[&_.stepper-step]:bg-[#F6F0FE] [&_.stepper-step]:text-[#653C94]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#653C94]",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-[#EEE0FD] [&_.stepper-compeleted-step_.stepper-step]:border-[#442863]",
      "dark:[&_.stepper-step]:bg-[#221431] dark:[&_.stepper-step]:text-[#CBA2FA]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#CBA2FA]",
      "dark:[&_.stepper-compeleted-step_.stepper-step]:bg-[#44286] dark:[&_.stepper-compeleted-step_.stepper-step]:border-[#DDC1FC]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#653C94] dark:[&_.stepper-seperator]:border-[#CBA2FA]",
      "[&_.stepper-compeleted-step+.stepper-seperator]:border-[#442863] dark:[&_.stepper-compeleted-step+.stepper-seperator]:border-[#DDC1FC]",
      "[&.vertical-stepper_.stepper-compeleted-step_.stepper-seperator]:border-[#442863]",
      "dark:[&.vertical-stepper_.stepper-compeleted-step_.stepper-seperator]:border-[#DDC1FC]"
    ]
  end

  defp color_class("dawn") do
    [
      "[&_.stepper-step]:bg-[#FBF2ED] [&_.stepper-step]:text-[#7E4B2A]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#7E4B2A]",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-[#F6E5DA] [&_.stepper-compeleted-step_.stepper-step]:border-[#54321C]",
      "dark:[&_.stepper-step]:bg-[#2A190E] dark:[&_.stepper-step]:text-[#E4B190]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#E4B190]",
      "dark:[&_.stepper-compeleted-step_.stepper-step]:bg-[#54321C] dark:[&_.stepper-compeleted-step_.stepper-step]:border-[#EDCBB5]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#7E4B2A] dark:[&_.stepper-seperator]:border-[#E4B190]",
      "[&_.stepper-compeleted-step+.stepper-seperator]:border-[#54321C] dark:[&_.stepper-compeleted-step+.stepper-seperator]:border-[#EDCBB5]",
      "[&.vertical-stepper_.stepper-compeleted-step_.stepper-seperator]:border-[#54321C]",
      "dark:[&.vertical-stepper_.stepper-compeleted-step_.stepper-seperator]:border-[#EDCBB5]"
    ]
  end

  defp color_class("silver") do
    [
      "[&_.stepper-step]:bg-[#F3F3F3] [&_.stepper-step]:text-[#727272]",
      "[&_.stepper-step]:border-transparent [&_.stepper-current-step_.stepper-step]:border-[#727272]",
      "[&_.stepper-compeleted-step_.stepper-step]:bg-[#E8E8E8] [&_.stepper-compeleted-step_.stepper-step]:border-[#5E5E5E]",
      "dark:[&_.stepper-step]:bg-[#4B4B4B] dark:[&_.stepper-step]:text-[#BBBBBB]",
      "dark:[&_.stepper-current-step_.stepper-step]:border-[#BBBBBB]",
      "dark:[&_.stepper-compeleted-step_.stepper-step]:bg-[#5E5E5E] dark:[&_.stepper-compeleted-step_.stepper-step]:border-[#DDDDDD]",
      "[&_.stepper-canceled-step_.stepper-step]:bg-[#950F22] [&_.stepper-canceled-step_.stepper-step]:border-[#950F22]",
      "[&_.stepper-canceled-step_.stepper-step]:text-white",
      "dark:[&_.stepper-canceled-step_.stepper-step]:bg-[#FFD2CD] dark:[&_.stepper-canceled-step_.stepper-step]:border-[#FFD2CD]",
      "dark:[&_.stepper-canceled-step_.stepper-step]:text-black",
      "[&_.stepper-seperator]:border-[#727272] dark:[&_.stepper-seperator]:border-[#BBBBBB]",
      "[&_.stepper-compeleted-step+.stepper-seperator]:border-[#5E5E5E] dark:[&_.stepper-compeleted-step+.stepper-seperator]:border-[#DDDDDD]",
      "[&.vertical-stepper_.stepper-compeleted-step_.stepper-seperator]:border-[#5E5E5E]",
      "dark:[&.vertical-stepper_.stepper-compeleted-step_.stepper-seperator]:border-[#DDDDDD]"
    ]
  end

  defp color_class(params) when is_binary(params), do: params

  defp color_class(_), do: color_class("natural")

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
