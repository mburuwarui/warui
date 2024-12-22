defmodule WaruiWeb.NotebookLive.Show do
  use WaruiWeb, :live_view

  on_mount {WaruiWeb.LiveUserAuth, :live_user_optional}

  @impl true
  def render(assigns) do
    ~H"""
    <section class="container mt-24 mx-auto max-w-2xl">
      <.header class="my-4">
        <.h6 color="natural">Notebook {@notebook.id}</.h6>
        <.small color="natural" size="small">This is a notebook record from your database.</.small>

        <:actions>
          <.link patch={~p"/notebooks/#{@notebook}/show/edit"} phx-click={JS.push_focus()}>
            <.button color="natural" variant="outline" icon="hero-pencil" icon_class="w-4 h-4">
              Edit notebook
            </.button>
          </.link>
        </:actions>
      </.header>

      <.list font_weight="font-bold" color="natural" size="small" variant="outline">
        <:item padding="small" title="Id" icon="hero-identification">{@notebook.id}</:item>

        <:item padding="small" title="Title" icon="hero-document">{@notebook.title}</:item>

        <:item padding="small" title="Body" icon="hero-document-text">{@notebook.body}</:item>

        <:item padding="small" title="Picture" icon="hero-photo">{@notebook.picture}</:item>

        <%!-- <:item padding="small" title="User">{@notebook.user_email}</:item> --%>
      </.list>

      <.back navigate={~p"/notebooks"}>Back to notebooks</.back>
    </section>

    <.modal
      :if={@live_action == :edit}
      id="notebook-modal"
      title={@page_title}
      show
      on_cancel={JS.patch(~p"/notebooks/#{@notebook}")}
      color="inverted"
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
       |> Ash.load!([:user_email])
     )}
  end

  defp page_title(:show), do: "Show Notebook"
  defp page_title(:edit), do: "Edit Notebook"
end
