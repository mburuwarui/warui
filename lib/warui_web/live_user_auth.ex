defmodule WaruiWeb.LiveUserAuth do
  @moduledoc """
  Helpers for authenticating users in LiveViews.
  """
  alias Warui.Treasury.Helpers.TypeCache

  import Phoenix.Component
  use WaruiWeb, :verified_routes

  @invalid_return_to ["auth", "sign-in", "sign-out"]

  # This is used for nested liveviews to fetch the current user.
  # To use, place the following at the top of that liveview:
  # on_mount {WaruiWeb.LiveUserAuth, :current_user}
  def on_mount(:current_user, _params, session, socket) do
    {:cont, AshAuthentication.Phoenix.LiveSession.assign_new_resources(socket, session)}
  end

  def on_mount(:live_user_optional, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:live_user_required, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:cont, socket}
    else
      {:halt,
       socket
       |> Phoenix.LiveView.put_flash(:error, "Admin access required")
       |> Phoenix.LiveView.redirect(to: ~p"/")}
    end
  end

  def on_mount(:live_no_user, _params, _session, socket) do
    if socket.assigns[:current_user] do
      {:halt, Phoenix.LiveView.redirect(socket, to: ~p"/")}
    else
      {:cont, assign(socket, :current_user, nil)}
    end
  end

  def on_mount(:admin_only, _params, _session, socket) do
    # If the user is logged in, check the user role is admin. Continue if so,
    # otherwise redirect to main page or a 403 page
    if socket.assigns[:current_user] do
      if socket.assigns[:current_user] |> TypeCache.user_role_is_admin() do
        {:cont, socket}
      else
        {:halt,
         socket
         |> Phoenix.LiveView.put_flash(:error, "Admin access required")
         |> Phoenix.LiveView.redirect(to: ~p"/")}
      end

      # If user isn't logged in, redirect to sign in page with return path
    else
      {:halt,
       socket
       |> Phoenix.LiveView.put_flash(:info, "Please sign in to continue")
       |> Phoenix.LiveView.redirect(to: ~p"/sign-in")}
    end
  end

  # Hook to save the current URI for return navigation
  def on_mount(:save_request_uri, _params, _session, socket) do
    {:cont,
     Phoenix.LiveView.attach_hook(
       socket,
       :save_request_path,
       :handle_params,
       &save_request_path/3
     )}
  end

  defp save_request_path(_params, url, socket) do
    path = URI.parse(url) |> Map.get(:path)

    # Only store if user is not authenticated and path is valid for return
    if socket.assigns[:current_user] || is_invalid_return_to(path) do
      {:cont, socket}
    else
      # Store the full URL path in session via a JavaScript command
      # Since we can't directly access session in LiveView, we'll use the URL itself
      current_uri = URI.parse(url)

      full_path =
        if current_uri.query do
          "#{current_uri.path}?#{current_uri.query}"
        else
          current_uri.path
        end

      {:cont, Phoenix.Component.assign(socket, :current_uri, full_path)}
    end
  end

  defp is_invalid_return_to(path) do
    @invalid_return_to
    |> Enum.any?(fn invalid -> String.contains?(path, invalid) end)
  end
end
