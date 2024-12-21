defmodule WaruiWeb.NotebookLive.FormComponent do
  use WaruiWeb, :live_component

  on_mount {WaruiWeb.LiveUserAuth, :live_user_required}

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header class="mb-4">
        <.small color="natural" size="small">Use this form to manage notebook records in your database.</.small>
      </.header>

      <.form_wrapper
        for={@form}
        id="notebook-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
        class="space-y-4"
        color="inverted"
      >
        <.text_field color="info" floating="inner" field={@form[:title]} label="Title" />
        <.textarea_field color="primary" rows="7" floating="inner" field={@form[:body]} type="textarea" label="Body" />
        <.url_field color="secondary" floating="inner" field={@form[:picture]} label="Picture" />

        <:actions>
          <.button
            color="primary"
            variant="default_gradient"
            class="my-4"
            phx-disable-with="Saving..."
          >
            Save Notebook
          </.button>
        </:actions>
      </.form_wrapper>
    </div>
    """
  end

  @impl true
  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_form()}
  end

  @impl true
  def handle_event("validate", %{"notebook" => notebook_params}, socket) do
    {:noreply,
     assign(socket, form: AshPhoenix.Form.validate(socket.assigns.form, notebook_params))}
  end

  def handle_event("save", %{"notebook" => notebook_params}, socket) do
    case AshPhoenix.Form.submit(socket.assigns.form, params: notebook_params) do
      {:ok, notebook} ->
        notify_parent({:saved, notebook})

        socket =
          socket
          |> put_flash(:info, "Notebook #{socket.assigns.form.source.type}d successfully")
          |> push_patch(to: socket.assigns.patch)

        {:noreply, socket}

      {:error, form} ->
        {:noreply, assign(socket, form: form)}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})

  defp assign_form(%{assigns: %{notebook: notebook}} = socket) do
    form =
      if notebook do
        AshPhoenix.Form.for_update(notebook, :update,
          as: "notebook",
          actor: socket.assigns.current_user
        )
      else
        AshPhoenix.Form.for_create(Warui.Catalog.Notebook, :create,
          as: "notebook",
          actor: socket.assigns.current_user
        )
      end

    assign(socket, form: to_form(form))
  end
end
