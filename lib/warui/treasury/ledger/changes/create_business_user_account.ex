defmodule Warui.Treasury.Ledger.Changes.CreateBusinessUserAccount do
  @moduledoc """
  Create a default Ledger and Account for a user
  """
  use Ash.Resource.Change
  alias Warui.Treasury.Helpers.TypeCache

  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, &create_default_user_account/2)
  end

  defp create_default_user_account(changeset, ledger) do
    user = changeset.context.private.actor
    organization_owner = Ash.Changeset.get_argument(changeset, :organization_owner)

    # Account types
    organization_account_type_id = TypeCache.account_type_id("Business", organization_owner)
    shop_account_type_id = TypeCache.account_type_id("Merchant", organization_owner)

    # Ledgers
    organization_ledger = TypeCache.ledger_by_owner(organization_owner.id, organization_owner)
    shop_ledger = ledger

    _business_accounts =
      [
        # Business account for organization interaction
        %{
          name: "Business Account",
          account_owner_id: ledger.ledger_owner_id,
          account_ledger_id: organization_ledger.id,
          account_type_id: organization_account_type_id,
          organization_owner: organization_owner,
          flags: %{
            history: true,
            credits_must_not_exceed_debits: true
          }
        },

        # Merchant Account for organizationplace shop
        %{
          name: "Merchant Account",
          account_owner_id: ledger.ledger_owner_id,
          account_ledger_id: shop_ledger.id,
          account_type_id: shop_account_type_id,
          organization_owner: organization_owner,
          flags: %{
            history: true,
            debits_must_not_exceed_credits: true
          }
        }
      ]
      |> Ash.bulk_create!(
        Warui.Treasury.Account,
        :bulk_create_with_tigerbeetle_account,
        batch_size: 100,
        return_records?: true,
        return_errors?: true,
        actor: user,
        tenant: user.current_organization
      )

    {:ok, ledger}
  end
end
