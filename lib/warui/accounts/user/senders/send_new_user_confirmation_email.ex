defmodule Warui.Accounts.User.Senders.SendNewUserConfirmationEmail do
  @moduledoc """
  Sends an email for a new user to confirm their email address.
  """

  use AshAuthentication.Sender
  use WaruiWeb, :verified_routes

  @impl true
  def send(user, token, _) do
    # Example of how you might send this email
    Warui.Accounts.Emails.send_new_user_confirmation_email(
      user,
      url(~p"/auth/user/confirm_new_user?#{[confirm: token]}")
    )

    IO.puts("""
    Click this link to confirm your email:

    #{url(~p"/auth/user/confirm_new_user?#{[confirm: token]}")}
    """)
  end
end
