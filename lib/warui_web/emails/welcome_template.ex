defmodule WaruiWeb.Emails.WelcomeTemplate do
  use MjmlEEx,
    mjml_template: "../mjml/welcome_template.mjml.eex",
    layout: WaruiWeb.Mjml.BaseLayout

  defp generate_full_name(first_name, last_name) do
    "#{first_name} #{last_name}"
  end
end
