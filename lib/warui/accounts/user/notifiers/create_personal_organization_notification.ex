defmodule Warui.Accounts.User.Notifiers.CreatePersonalOrganizationNotification do
  alias Warui.Treasury.Helpers.Seeder
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
    # Determine the count of existing organization and use it as a
    # suffix to the organization domain.
    organization_count = Ash.count!(Warui.Accounts.Organization) + 1

    organization_attrs = %{
      name: "Personal Organization",
      domain: "personal_organization_#{organization_count}",
      owner_user_id: user.id
    }

    organization = Ash.create!(Warui.Accounts.Organization, organization_attrs)

    Seeder.seed_treasury_types(organization.domain)
  end
end
