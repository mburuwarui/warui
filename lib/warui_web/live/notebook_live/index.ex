defmodule WaruiWeb.NotebookLive.Index do
  use WaruiWeb, :live_view
  on_mount {WaruiWeb.LiveUserAuth, :live_user_optional}

  @impl true
  def render(assigns) do
    ~H"""
    <section class="container px-4 py-20 sm:px-6 lg:px-8 max-w-5xl mx-auto">
      <.header class="my-4">
        <.h3 color="natural">Listing Notebooks</.h3>
        <:actions>
          <.link patch={~p"/notebooks/new"}>
            <.button color="natural" variant="outline" icon="hero-squares-plus" icon_class="w-4 h-4">
              New Notebook
            </.button>
          </.link>
        </:actions>
      </.header>

      <.table
        color="inverted"
        variant="bordered"
        border="large"
        header_border="extra_small"
        rows_border="extra_small"
        cols_border="extra_small"
        rounded="large"
        padding="small"
      >
        <:header><.checkbox_field name="home" value="Home" color="inverted" space="small" size="large" /></:header>
        <:header>Title</:header>
        <:header>Body</:header>
        <:header>Picture</:header>
        <:header>Author</:header>
        <:header><.icon name="hero-ellipsis-horizontal" class="w-4 h-4" /></:header>


        <tbody id="notebooks" phx-update="stream">
          <.tr :for={{dom_id, notebook} <- @streams.notebooks} id={dom_id}>
            <.td><.checkbox_field name="home" value="Home" color="inverted" space="small" size="large" /></.td>
            <.td>{notebook.title}</.td>
            <.td>{notebook.body}</.td>
            <.td>{notebook.picture}</.td>
            <.td>{notebook.user_email}</.td>
            <.td>
              <.link navigate={~p"/notebooks/#{notebook}"}>
                <.icon name="hero-eye" class="w-4 h-4" />
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
    </section>

    <.modal
      :if={@live_action in [:new, :edit]}
      id="notebook-modal"
      title={@page_title}
      show
      on_cancel={JS.patch(~p"/notebooks")}
      color="inverted"
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
