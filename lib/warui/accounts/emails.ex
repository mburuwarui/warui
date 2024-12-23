defmodule Warui.Accounts.Emails do
  @moduledoc """
  Helpers for sending emails
  """

  import Swoosh.Email

  def send_password_reset_email(user, url) do
    if !url do
      raise "Cannot deliver reset instructions without a url"
    end

    deliver(user.email, "Reset Your Password", """
    <html>
      <p>
        Hi #{user.email},
      </p>

      <p>
        <a href="#{url}">Click here</a> to reset your password.
      </p>

      <p>
        If you didn't request this change, please ignore this.
      </p>
    <html>
    """)
  end

  def send_magic_link_email(user_or_email, url) do
    if !url do
      raise "Cannot deliver reset instructions without a url"
    end

    email =
      case user_or_email do
        %{email: email} -> email
        email -> email
      end

    deliver(email, "Magic Link", """
    <html>
      <p>
        Hi #{email},
      </p>

      <p>
        <a href="#{url}">Click here</a> to login.
      </p>
    <html>
    """)
  end

  def send_new_user_confirmation_email(user, url) do
    if !url do
      raise "Cannot deliver confirmation instructions without a url"
    end

    deliver(user.email, "Confirm your email address", """
      <html>
        <p>
          Hi #{user.email},
        </p>

        <p>
          Someone has tried to register a new account using this email address.
          If it was you, then please click the link below to confirm your identity. If you did not initiate this request then please ignore this email.
        </p>

        <p>
          <a href="#{url}">Click here to confirm your account</a>
        </p>
      <html>
    """)
  end

  def send_email_change_confirmation(user, url) do
    if !url do
      raise "Cannot deliver confirmation instructions without a url"
    end

    deliver(user.email, "Confirm your new email address", """
      <p>
        Hi #{user.email},
      </p>

      <p>
        You recently changed your email address. Please confirm it.
      </p>

      <p>
        <a href="#{url}">Click here to confirm your new email address</a>
      </p>
    """)
  end

  # For simplicity, this module simply logs messages to the terminal.
  # You should replace it by a proper email or notification tool, such as:
  #
  #   * Swoosh - https://hexdocs.pm/swoosh
  #   * Bamboo - https://hexdocs.pm/bamboo
  #
  defp deliver(to, subject, body) do
    IO.puts("Sending email to #{to} with subject #{subject} and body #{body}")

    new()
    |> from({"Warui", "mburu@warui.cc"})
    |> to(to_string(to))
    |> subject(subject)
    |> put_provider_option(:track_links, "None")
    |> html_body(body)
    |> Warui.Mailer.deliver!()
  end
end
