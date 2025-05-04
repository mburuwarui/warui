defmodule AccountCase do
  alias Warui.Treasury.Helpers.TypeCache
  alias Warui.Treasury.Account

  def create_account(account_name, ledger_id) do
    user = TypeCache.ledger_user(ledger_id)
    account_type_id = TypeCache.account_type_id("Checking", user)

    account_attrs = %{
      name: account_name,
      account_owner_id: user.id,
      account_ledger_id: ledger_id,
      account_type_id: account_type_id,
      flags: %{
        history: true
      }
    }

    Ash.create!(Account, account_attrs, actor: user)
  end
end
