defmodule WaruiWeb.Emails.Email do
  import Swoosh.Email

  # Your existing deliver function
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

  # Add a new function to send emails using your MJML template
  def send_test_email(to, first_name, last_name) do
    # Generate HTML from MJML template
    html_body =
      WaruiWeb.Emails.BasicTemplate.render(
        first_name: first_name,
        last_name: last_name
      )

    deliver(
      to,
      "Test MJML Email",
      html_body
    )
  end

  def send_welcome_email(
        to,
        first_name,
        last_name
      ) do
    # Generate HTML from MJML template
    html_body =
      WaruiWeb.Emails.WelcomeTemplate.render(
        email_title: "Welcome to Our Platform",
        first_name: first_name,
        last_name: last_name,
        call_to_action_text: "Get Started Now!",
        call_to_action_link: "https://example.com/start"
      )

    deliver(
      to,
      "Test MJML Email",
      html_body
    )
  end
end
