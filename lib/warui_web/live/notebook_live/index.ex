defmodule WaruiWeb.NotebookLive.Index do
  use WaruiWeb, :live_view
  on_mount {WaruiWeb.LiveUserAuth, :live_user_optional}

  @impl true
  def render(assigns) do
    ~H"""
    <.header class="my-4">
      Listing Notebooks
      <:actions>
        <.link patch={~p"/notebooks/new"}>
          <.button>New Notebook</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      color="natural"
      variant="hoverable"
      border="large"
      header_border="extra_small"
      rows_border="extra_small"
      cols_border="extra_small"
      rounded="large"
      padding="small"
    >
      <:header>Title</:header>
      <:header>Body</:header>
      <:header>Picture</:header>
      <:header>Author</:header>

      <tbody id="notebooks" phx-update="stream">
        <.tr :for={{dom_id, notebook} <- @streams.notebooks} id={dom_id}>
          <.td>{notebook.title}</.td>
          <.td>{notebook.body}</.td>
          <.td>{notebook.picture}</.td>
          <.td>{notebook.user_email}</.td>
          <.td>
            <.link navigate={~p"/notebooks/#{notebook}"}>
              Show
            </.link>
          </.td>
          <.td>
            <.link navigate={~p"/notebooks/#{notebook}/edit"}>
              <.icon name="hero-pencil" class="w-4 h-4" />
            </.link>
          </.td>

          <.td>
            <.link
              phx-click={
                JS.push("delete", value: %{id: notebook.id})
                # |> JS.dispatch("notebooks:debug",
                #   detail: %{
                #     dom_id: dom_id,
                #     notebook_id: notebook.id
                #   }
                # )
                |> hide("##{dom_id}")
              }
              data-confirm="Are you sure?"
            >
              <.icon name="hero-trash" class="w-4 h-4" />
            </.link>
          </.td>
        </.tr>
      </tbody>
    </.table>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="notebook-modal"
      show
      on_cancel={JS.patch(~p"/notebooks")}
      color="natural"
      variant="shadow"
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
    notebooks =
      Ash.read!(Warui.Catalog.Notebook, actor: socket.assigns[:current_user])
      |> Ash.load!([:user_email])

    {:ok,
     socket
     |> stream(:notebooks, notebooks)
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
    {:noreply, stream_insert(socket, :notebooks, notebook, at: 0)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    notebook = Ash.get!(Warui.Catalog.Notebook, id, actor: socket.assigns.current_user)
    Ash.destroy!(notebook, actor: socket.assigns.current_user)

    {:noreply,
     socket
     |> stream_delete(:notebooks, notebook)
     |> put_flash(:info, "Notebook deleted successfully.")}
  end
end
