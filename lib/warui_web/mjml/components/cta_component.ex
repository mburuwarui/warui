defmodule WaruiWeb.MyTemplate.CtaComponent do
  use MjmlEEx.Component, mode: :runtime

  @impl MjmlEEx.Component
  def render(assigns) do
    """
    <mj-column>
      <mj-text font-size="20px" color="#F45E43">#{assigns[:call_to_action_text]}</mj-text>
      <mj-button align="center" inner-padding="12px 20px">#{assigns[:call_to_action_link]}</mj-button>
    </mj-column>
    """
  end
end
