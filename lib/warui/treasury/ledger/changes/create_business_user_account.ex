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
    market_owner = Ash.Changeset.get_argument(changeset, :market_owner)

    # Account types
    market_account_type_id = TypeCache.account_type_id("Business", market_owner)
    shop_account_type_id = TypeCache.account_type_id("Merchant", market_owner)

    # Tenant
    market_tenant = market_owner.current_organization

    # Ledgers
    market_ledger = TypeCache.ledger_by_owner(market_owner.id, market_tenant)
    shop_ledger = ledger

    _business_accounts =
      [
        # Business account for marketplace interaction
        %{
          name: "Business Account",
          account_owner_id: ledger.ledger_owner_id,
          account_ledger_id: market_ledger.id,
          account_type_id: market_account_type_id,
          tenant: market_tenant,
          flags: %{
            history: true,
            credits_must_not_exceed_debits: true
          }
        },

        # Merchant Account for marketplace shop
        %{
          name: "Merchant Account",
          account_owner_id: ledger.ledger_owner_id,
          account_ledger_id: shop_ledger.id,
          account_type_id: shop_account_type_id,
          tenant: market_tenant,
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
