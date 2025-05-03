defmodule Warui.Accounts.User.Changes.CreateTigerBeetleAccount do
  use Ash.Resource.Change
  alias Warui.Treasury.Helpers.TigerbeetleService
  require Logger

  @doc """
  Creates a TigerBeetle account for a user after the user resource is created.

  Options:
  * :currency - The currency code for the account (default: "KES")
  """
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_transaction(changeset, &create_tigerbeetle_account/2)
  end

  defp create_tigerbeetle_account(changeset, {:ok, account}) do
    user = changeset.context.private.actor
    locale = Gettext.get_locale()

    attrs = %{
      id: account.id,
      ledger: account.account_ledger_id,
      code: account.account_type_id,
      user_data_128: account.account_owner_id,
      user_data_64: account.created_at,
      user_data_32: locale,
      flags: account.flags
    }

    TigerbeetleService.create_account(attrs, user)
  end
end
