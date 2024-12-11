defmodule WaruiWeb.NotebookLive.Show do
  use WaruiWeb, :live_view

  on_mount {WaruiWeb.LiveUserAuth, :live_user_optional}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Notebook {@notebook.id}
      <:subtitle>This is a notebook record from your database.</:subtitle>

      <:actions>
        <.link patch={~p"/notebooks/#{@notebook}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit notebook</.button>
        </.link>
      </:actions>
    </.header>

    <.list>
      <:item title="Id">{@notebook.id}</:item>

      <:item title="Title">{@notebook.title}</:item>

      <:item title="Body">{@notebook.body}</:item>

      <:item title="Picture">{@notebook.picture}</:item>

      <:item title="User">{@notebook.user_id}</:item>
    </.list>

    <.back navigate={~p"/notebooks"}>Back to notebooks</.back>

    <.modal
      :if={@live_action == :edit}
      id="notebook-modal"
      show
      on_cancel={JS.patch(~p"/notebooks/#{@notebook}")}
    >
      <.live_component
        module={WaruiWeb.NotebookLive.FormComponent}
        id={@notebook.id}
        title={@page_title}
        action={@live_action}
        current_user={@current_user}
        notebook={@notebook}
        patch={~p"/notebooks/#{@notebook}"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(
       :notebook,
       Ash.get!(Warui.Catalog.Notebook, id, actor: socket.assigns.current_user)
     )}
  end

  defp page_title(:show), do: "Show Notebook"
  defp page_title(:edit), do: "Edit Notebook"
end
