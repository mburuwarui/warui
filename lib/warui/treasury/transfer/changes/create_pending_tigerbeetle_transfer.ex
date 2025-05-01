defmodule Warui.Treasury.Transfer.Changes.CreatePendingTigerbeetleTransfer do
  use Ash.Resource.Change
  alias TigerBeetlex.{Transfer, TransferFlags}
  alias Warui.Treasury.Helpers.TigerbeetleService
  alias Warui.Treasury.Helpers.TypeCache
  require Logger

  @doc """
  Creates a TigerBeetle pending transfer for a user when a transfer resource is created.

  Options:
  * :currency - The currency code for the transfer (default: "KES")
  """
  def change(changeset, _opts, _context) do
    Ash.Changeset.before_transaction(changeset, &create_tigerbeetle_transfer/2)
  end

  defp create_tigerbeetle_transfer(changeset, {:ok, transfer}) do
    user = changeset.context.actor
    linked = Ash.Changeset.get_argument(changeset, :linked)

    transfer_type = TypeCache.get_transfer_type_by_id(transfer.transfer_type_id, user)
    ledger = TypeCache.get_ledger_asset_type_by_id(transfer.transfer_ledger_id, user)
    from_account = TypeCache.get_account_by_id(transfer.from_account_id, user)
    to_account = TypeCache.get_account_by_id(transfer.to_account_id, user)
    locale = Gettext.get_locale()

    tb_transfer = %Transfer{
      id: TigerbeetleService.uuidv7_to_128bit(transfer.id),
      user_data_128: TigerbeetleService.uuidv7_to_128bit(transfer.transfer_owner_id),
      user_data_64: TigerbeetleService.timestamp_to_user_data_64(),
      user_data_32: TigerbeetleService.get_locale_code(locale),
      ledger: ledger.code,
      code: transfer_type.code,
      amount: transfer.amount,
      debit_account_id: from_account.id,
      credit_account_id: to_account.id,
      flags: %TransferFlags{
        pending: true,
        linked: linked
      }
    }

    case TigerBeetlex.Connection.create_transfers(:tb, [tb_transfer]) do
      {:ok, _ref} ->
        Logger.info(
          "TigerBeetle transfer ensured for user #{transfer.transfer_owner_id} (idempotent operation succeeded)"
        )

        {:ok, transfer}

      {:error, reason} ->
        Logger.error("Failed to create TigerBeetle transfer: #{inspect(reason)}")
        {:ok, transfer}
    end
  end
end
