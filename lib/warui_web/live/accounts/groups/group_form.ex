defmodule WaruiWeb.Accounts.Groups.GroupForm do
  use WaruiWeb, :live_component

  alias AshPhoenix.Form

  @doc """
  This a wrapper used to access this component like a static component
  in the template.

  example:
    <WaruiWeb.Accounts.Groups.GroupForm.form
      :for={group <- @groups}
      actor={@current_user}
      group_id={group.id}
      show_button={false}
      id={group.id}
    />

  """
  attr :id, :string, required: true
  attr :group_id, :string, default: nil
  attr :show_button, :boolean, default: true, doc: "Show button to create new group"
  attr :actor, Warui.Accounts.User, required: true

  def form(assigns) do
    ~H"""
    <.live_component
      id={@id}
      actor={@actor}
      module={__MODULE__}
      group_id={@group_id}
      show_button={@show_button}
    />
    """
  end

  attr :id, :string, required: true
  attr :group_id, :string, default: nil
  attr :show_button, :boolean, default: true
  attr :actor, Warui.Accounts.User, required: true

  def render(assigns) do
    ~H"""
    <div id={"access-group-#{@group_id}"} class="mt-4">
      <%!-- Form modal trigger Button --%>
      <div class="flex justify-end">
        <.button
          :if={@show_button}
          class="btn"
          color="primary"
          variant="inverted"
          phx-click={show_modal(%JS{}, "access-group-form-modal#{@group_id}")}
          id={"access-group-modal-button#{@group_id}"}
        >
          <.icon name="hero-plus-solid" class="h-5 w-5" />
        </.button>
      </div>

      <%!-- We want this form to show-up in a modal --%>
      <.modal color="natural" variant="bordered" id={"access-group-form-modal#{@group_id}"}>
        <.header class="mt-4">
          <.icon name="hero-user-group" />
          <%!-- New Group --%>
          <.h4 :if={is_nil(@group_id)} class="text-base-700">
            {gettext("New Access Group")}
          </.h4>
          <:subtitle :if={is_nil(@group_id)}>
            <.p class="text-base-500">
              {gettext("Fill below form to create a new user access group")}
            </.p>
          </:subtitle>

          <%!-- Existing group --%>
          <span :if={@group_id}>{@form.source.data.name}</span>
          <:subtitle :if={@group_id}>
            {gettext("Fill below form to update %{name} access group details.",
              name: @form.source.data.name
            )}
          </:subtitle>
        </.header>
        <.form_wrapper
          variant="default"
          space="large"
          rounded="small"
          padding="medium"
          for={@form}
          phx-change="validate"
          phx-submit="save"
          id={"access-group-form#{@group_id}"}
          phx-target={@myself}
        >
          <.text_field
            field={@form[:name]}
            id={"access-group-name#{@id}-#{@group_id}"}
            label={gettext("Access Group Name")}
            color="primary"
            variant="outline"
          />
          <.textarea_field
            field={@form[:description]}
            id={"access-group-description#{@id}-#{@group_id}"}
            label={gettext("Description")}
            color="primary"
            variant="outline"
          />
          <:actions>
            <.button variant="default" class="btn w-full" phx-disable-with={gettext("Saving...")}>
              {gettext("Submit")}
            </.button>
          </:actions>
        </.form_wrapper>
      </.modal>
    </div>
    """
  end

  def update(assigns, socket) do
    socket
    |> assign(assigns)
    |> assign_form()
    |> ok()
  end

  def handle_event("validate", %{"form" => attrs}, socket) do
    socket
    |> assign(:form, Form.validate(socket.assigns.form, attrs))
    |> noreply()
  end

  def handle_event("save", %{"form" => attrs}, socket) do
    case Form.submit(socket.assigns.form, params: attrs) do
      {:ok, _group} ->
        socket
        |> put_component_flash(:info, gettext("Access Group Submitted."))
        |> cancel_modal("access-group-form-modal#{socket.assigns.group_id}")
        |> noreply()

      {:error, form} ->
        socket
        |> assign(:form, form)
        |> noreply()
    end
  end

  # Prevents the form from being re-created on every update
  defp assign_form(%{assigns: %{form: _form}} = socket), do: socket

  defp assign_form(%{assigns: assigns} = socket) do
    assign(socket, :form, get_form(assigns))
  end

  # Build for the new access group
  defp get_form(%{group_id: nil} = assigns) do
    Warui.Accounts.Group
    |> Form.for_create(:create, actor: assigns.actor)
    |> to_form()
  end

  # Build for the existing access group
  defp get_form(%{group_id: group_id} = assigns) do
    Warui.Accounts.Group
    |> Ash.get!(group_id, actor: assigns.actor)
    |> Form.for_update(:update, actor: assigns.actor)
    |> to_form()
  end
end
