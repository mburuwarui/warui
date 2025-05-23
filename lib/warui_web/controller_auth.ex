defmodule WaruiWeb.ControllerAuth do
  @moduledoc """
  Helpers for authenticating users in Controllers.
  """
  alias Warui.Treasury.Helpers.TypeCache
  import Phoenix.Controller
  import Plug.Conn
  use WaruiWeb, :verified_routes

  def init(opts), do: opts

  def call(conn, :admin_only) do
    admin_only(conn, [])
  end

  def admin_only(conn, _opts) do
    # If the user is logged in, check the user role is admin. Continue if so,
    # otherwise redirect to main page or a 403 page
    if conn.assigns[:current_user] do
      if conn.assigns[:current_user] |> TypeCache.user_role_is_admin() do
        conn
      else
        conn
        |> redirect(to: ~p"/")
        |> halt()
      end

      # If user isn't logged in, redirect to sign in page
    else
      conn
      |> redirect(to: ~p"/sign-in")
      |> halt()
    end
  end
end

