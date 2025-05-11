defmodule Warui.Accounts.UserOrganization.Changes.AddUsersToExistingOrganization do
  alias Warui.Treasury.UserLedger
  alias Warui.Treasury.Helpers.TypeCache
  alias Warui.Treasury.Ledger
  use Ash.Resource.Change

  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, &create_default_ledger_and_account/2)
  end

  def batch_change(changesets, _opts, _context) do
    Enum.map(changesets, fn changeset ->
      Ash.Changeset.after_action(changeset, &create_default_ledger_and_account/2)
    end)
  end

  defp create_default_ledger_and_account(_changeset, user_organization) do
    user_id = user_organization.user_id
    organization_id = user_organization.organization_id
    organization_owner = TypeCache.organization_owner(organization_id)
    # shop_owner = TypeCache.user(user_id)
    TypeCache.init_caches(organization_owner)
    asset_type_id = TypeCache.asset_type_id("Cash", organization_owner)
    currency_id = TypeCache.currency_id("Kenya Shilling", organization_owner)

    params = %{
      name: "Shop",
      asset_type_id: asset_type_id,
      currency_id: currency_id,
      ledger_owner_id: user_id,
      organization_owner: organization_owner
    }

    # Create ledger for user under organization
    {:ok, ledger} =
      Ledger
      |> Ash.Changeset.for_create(:create_business_ledger_under_existing_organization, params,
        actor: organization_owner
      )
      |> Ash.create()

    # Add user to his/her own ledger membership
    {:ok, _user_ledger} =
      UserLedger
      |> Ash.Changeset.for_create(:create, %{user_id: user_id, ledger_id: ledger.id},
        actor: organization_owner
      )
      |> Ash.create()

    # Fetch organization ledger
    ledger_owner_id = organization_owner.id
    ledger_owner = organization_owner

    organization_ledger =
      TypeCache.ledger_by_owner(ledger_owner_id, ledger_owner)

    # Add user to organization ledger membership
    {:ok, _user_ledger} =
      UserLedger
      |> Ash.Changeset.for_create(:create, %{user_id: user_id, ledger_id: organization_ledger.id},
        actor: organization_owner
      )
      |> Ash.create()

    {:ok, user_organization}
  end
end
