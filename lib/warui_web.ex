defmodule WaruiWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, components, channels, and so on.

  This can be used in your application as:

      use WaruiWeb, :controller
      use WaruiWeb, :html

  The definitions below will be executed for every controller,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define additional modules and import
  those modules here.
  """

  def static_paths, do: ~w(assets fonts images favicon.ico robots.txt)

  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
    end
  end

  def controller do
    quote do
      use Phoenix.Controller, formats: [:html, :json]

      use Gettext, backend: WaruiWeb.Gettext

      import Plug.Conn

      unquote(verified_routes())
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView

      @doc """
      Puts flash from a live components
      ### Example
        socket
        |> put_component_flash(:info, "Saved!")
        |> noreply()

      """
      def put_component_flash(socket, type, message) do
        send(self(), {:put_flash, type, message})
        socket
      end

      @doc """
      Use Phoenix inbuild javascript executor to cancel modal
      """
      def cancel_modal(socket, id) do
        push_event(socket, "js-exec", %{to: "##{@id}", attr: "data-cancel"})
      end

      unquote(html_helpers())
    end
  end

  def live_component do
    quote do
      use Phoenix.LiveComponent

      unquote(html_helpers())
    end
  end

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # Translation
      use Gettext, backend: WaruiWeb.Gettext

      # HTML escaping functionality
      import Phoenix.HTML
      # Core UI components
      use WaruiWeb.Components.MishkaComponents

      # Common modules used in templates
      alias Phoenix.LiveView.JS
      alias WaruiWeb.Layouts

      # Routes generation with the ~p sigil
      unquote(verified_routes())

      # Live view and live components callbacks helpers
      def ok(socket), do: {:ok, socket}
      def halt(socket), do: {:halt, socket}
      def continue(socket), do: {:cont, socket}
      def noreply(socket), do: {:noreply, socket}
    end
  end

  def verified_routes do
    quote do
      use Phoenix.VerifiedRoutes,
        endpoint: WaruiWeb.Endpoint,
        router: WaruiWeb.Router,
        statics: WaruiWeb.static_paths()
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/live_view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
