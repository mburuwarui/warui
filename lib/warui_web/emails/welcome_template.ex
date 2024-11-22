defmodule WaruiWeb.Emails.WelcomeTemplate do
  use MjmlEEx,
    mjml_template: "../mjml/welcome_template.mjml.eex",
    mjml_layout: "../mjml/layouts/base_layout.ex"

  defp generate_full_name(first_name, last_name) do
    "#{first_name} #{last_name}"
  end
end
