defmodule Warui.Accounts.User.Changes.CloseTigerBeetleAccount do
  use Ash.Resource.Change
  alias Warui.Treasury.Helpers.TigerbeetleService

  @doc """
  Closes a TigerBeetle account for a closing entry calculates the net debit or 
  credit balance for an account and then credits or debits this balance respectively,
  to zero the account’s balance and move the balance to another account.

  Options:
  * :currency - The currency code for the account (default: "KES")
  """
  def change(changeset, _opts, _context) do
    Ash.Changeset.before_transaction(changeset, &close_tigerbeetle_account/2)
  end

  defp close_tigerbeetle_account(changeset, {:ok, account}) do
    user = changeset.context.private.actor
    locale = Gettext.get_locale()

    attrs = %{
      id: account.id,
      user_data_128: account.account_owner_id,
      user_data_64: account.updated_at,
      user_data_32: locale,
      flags: %{
        closed: true
      }
    }

    case TigerbeetleService.create_account(attrs, user) do
      {:ok, _} -> {:ok, account}
      {:error, error} -> Ash.Changeset.add_error(changeset, error)
    end
  end
end
