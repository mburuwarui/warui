defmodule Warui.Accounts.User.Changes.ReopenTigerBeetleAccount do
  use Ash.Resource.Change
  alias TigerBeetlex.{Account, AccountFlags}
  alias Warui.Treasury.Helpers.TigerbeetleService
  alias Warui.Treasury.Helpers.TypeCache
  require Logger

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
    tenant = Ash.Changeset.get_argument(changeset, :tenant)

    asset_type = TypeCache.get_ledger_asset_type_by_id(account.ledger_id, tenant)
    account_type = TypeCache.get_account_type_by_id(account.account_type_id, tenant)

    tb_account = %Account{
      id: TigerbeetleService.uuidv7_to_128bit(account.id),
      ledger: asset_type.code,
      code: account_type.code,
      flags: %AccountFlags{closed: false}
    }

    case TigerBeetlex.Connection.create_accounts(:tb, [tb_account]) do
      {:ok, _ref} ->
        Logger.info(
          "TigerBeetle account reopened for user #{account.owner_id} (idempotent operation succeeded)"
        )

        {:ok, account}

      {:error, reason} ->
        Logger.error("Failed to reopen TigerBeetle account: #{inspect(reason)}")
        {:ok, account}
    end
  end
end
