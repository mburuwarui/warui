defmodule LedgerCase do
  alias Warui.Treasury.Helpers.TypeCache
  alias Warui.Treasury.Ledger

  def create_ledger(ledger_name, user_id, tenant) do
    user = TypeCache.user(user_id, tenant)

    currency_id = TypeCache.currency_id("Kenya Shilling", user)
    asset_type_id = TypeCache.asset_type_id("Cash", user)

    ledger_attrs = %{
      name: ledger_name,
      currency_id: currency_id,
      asset_type_id: asset_type_id,
      ledger_owner_id: user.id
    }

    Ash.create!(Ledger, ledger_attrs, actor: user)
  end
end
