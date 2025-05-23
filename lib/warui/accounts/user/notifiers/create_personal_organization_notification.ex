defmodule Warui.Accounts.User.Notifiers.CreatePersonalOrganizationNotification do
  alias Ash.Notifier.Notification
  use Ash.Notifier

  def notify(%Notification{data: user, action: %{name: :register_with_password}}) do
    create_personal_organization(user)
  end

  def notify(%Notification{data: user, action: %{name: :sign_in_with_magic_link}}) do
    create_personal_organization(user)
  end

  def notify(%Notification{} = _notification), do: :ok

  defp create_personal_organization(user) do
    # Extract the local part from the email
    email_local_part = user.email |> String.split("@") |> List.first()

    # Determine the count of existing organization and use it as a
    # suffix to the organization domain.
    organization_count = Ash.count!(Warui.Accounts.Organization) + 1

    organization_name = "#{email_local_part}'s Personal Organization"
    organization_domain = "#{email_local_part}_personal_organization_#{organization_count}"

    organization_attrs = %{
      name: organization_name,
      domain: organization_domain,
      owner_user_id: user.id
    }

    Ash.create!(Warui.Accounts.Organization, organization_attrs)
  end
end
