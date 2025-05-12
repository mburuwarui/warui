defmodule WaruiWeb.Accounts.Groups.GroupPermissionsLive do
  use WaruiWeb, :live_view

  def render(assigns) do
    ~H"""
    <.back navigate={~p"/accounts/groups"}>{gettext("Back to access groups")}</.back>
    <.header class="mt-4">
      <.icon name="hero-shield-check" /> {gettext("%{name} Access Permissions", name: @group.name)}
      <:subtitle>{@group.description}</:subtitle>
    </.header>

    <%!-- Group permissions --%>
    <div class="mt-4">
      <WaruiWeb.Accounts.Groups.GroupPermissionsForm.form group_id={@group_id} actor={@current_user} />
    </div>
    """
  end

  def mount(%{"group_id" => group_id}, _session, socket) do
    socket
    |> assign(:group_id, group_id)
    |> assign_group()
    |> ok()
  end

  defp assign_group(socket) do
    %{current_user: actor, group_id: group_id} = socket.assigns
    assign(socket, :group, get_group(actor, group_id))
  end

  defp get_group(actor, group_id) do
    Ash.get!(Warui.Accounts.Group, group_id, actor: actor)
  end
end
