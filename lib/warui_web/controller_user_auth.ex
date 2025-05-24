defmodule WaruiWeb.ControllerUserAuth do
  @moduledoc """
  Helpers for authenticating users in Controllers.
  """
  alias Warui.Treasury.Helpers.TypeCache
  import Phoenix.Controller
  import Plug.Conn
  use WaruiWeb, :verified_routes

  @invalid_return_to ["auth", "sign-in", "sign-out", "dev"]

  def init(opts), do: opts

  def call(conn, :admin_only) do
    admin_only(conn, [])
  end

  def call(conn, :remember_return_path) do
    remember_return_path(conn, [])
  end

  def admin_only(conn, _opts) do
    # If the user is logged in, check the user role is admin. Continue if so,
    # otherwise redirect to main page or a 403 page
    if conn.assigns[:current_user] do
      if conn.assigns[:current_user] |> TypeCache.user_role_is_admin() do
        conn
      else
        conn
        |> put_flash(:error, "Admin access required")
        |> redirect(to: ~p"/")
        |> halt()
      end

      # If user isn't logged in, redirect to sign in page
    else
      conn
      |> store_return_path()
      |> put_flash(:info, "Please sign in to continue")
      |> redirect(to: ~p"/sign-in")
      |> halt()
    end
  end

  def remember_return_path(conn, _opts) do
    # Store the current path in session for unauthenticated users
    # This allows redirecting back after sign in
    if conn.assigns[:current_user] do
      conn
    else
      store_return_path(conn)
    end
  end

  defp store_return_path(conn) do
    if is_invalid_return_to(conn.request_path) do
      conn
    else
      full_path = add_query_parameter(conn.request_path, conn.query_string)
      put_session(conn, :return_to, full_path)
    end
  end

  defp is_invalid_return_to(path) do
    @invalid_return_to
    |> Enum.any?(fn invalid -> String.contains?(path, invalid) end)
  end

  defp add_query_parameter(path, query) do
    if query == "" do
      path
    else
      "#{path}?#{query}"
    end
  end
end
