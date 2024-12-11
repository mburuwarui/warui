defmodule WaruiWeb.NotebookLive.Index do
  use WaruiWeb, :live_view
  on_mount {WaruiWeb.LiveUserAuth, :live_user_optional}

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Notebooks
      <:actions>
        <.link patch={~p"/notebooks/new"}>
          <.button>New Notebook</.button>
        </.link>
      </:actions>
    </.header>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="notebook-modal"
      show
      on_cancel={JS.patch(~p"/notebooks")}
    >
      <.live_component
        module={WaruiWeb.NotebookLive.FormComponent}
        id={(@notebook && @notebook.id) || :new}
        title={@page_title}
        current_user={@current_user}
        action={@live_action}
        notebook={@notebook}
        patch={~p"/notebooks"}
      />
    </.modal>
    """
  end

  @impl true
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> stream(
       :notebooks,
       Ash.read!(Warui.Catalog.Notebook, actor: socket.assigns[:current_user])
     )
     |> assign_new(:current_user, fn -> nil end)}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Notebook")
    |> assign(:notebook, Ash.get!(Warui.Catalog.Notebook, id, actor: socket.assigns.current_user))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Notebook")
    |> assign(:notebook, nil)
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Notebooks")
    |> assign(:notebook, nil)
  end

  @impl true
  def handle_info({WaruiWeb.NotebookLive.FormComponent, {:saved, notebook}}, socket) do
    {:noreply, stream_insert(socket, :notebooks, notebook)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    notebook = Ash.get!(Warui.Catalog.Notebook, id, actor: socket.assigns.current_user)
    Ash.destroy!(notebook, actor: socket.assigns.current_user)

    {:noreply, stream_delete(socket, :notebooks, notebook)}
  end
end
