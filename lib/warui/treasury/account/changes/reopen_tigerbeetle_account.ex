defmodule Warui.Accounts.User.Changes.ReopenTigerBeetleAccount do
  use Ash.Resource.Change
  alias Warui.Treasury.Helpers.TigerbeetleService

  @doc """
  Reopens a TigerBeetle account. To re-open the closed account, the pending closing 
  transfer can be voided, reverting the closing action (but not reverting the net balance

  Options:
  * :currency - The currency code for the account (default: "KES")
  """
  def change(changeset, _opts, _context) do
    Ash.Changeset.before_transaction(changeset, &close_tigerbeetle_account/2)
  end

  defp close_tigerbeetle_account(changeset, {:ok, account}) do
    user = changeset.context.private.actor
    organization_owner = Ash.Changeset.get_argument(changeset, :organization_owner)
    locale = Gettext.get_locale()

    attrs = %{
      id: account.id,
      user_data_128: account.account_owner_id,
      user_data_64: account.updated_at,
      user_data_32: locale,
      flags: %{
        closed: false
      }
    }

    case TigerbeetleService.create_account(attrs, user, organization_owner) do
      {:ok, _} -> {:ok, account}
      {:error, error} -> Ash.Changeset.add_error(changeset, error)
    end
  end
end
