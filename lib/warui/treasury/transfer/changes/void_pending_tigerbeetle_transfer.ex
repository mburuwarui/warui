defmodule Warui.Treasury.Transfer.Changes.VoidPendingTigerbeetleTransfer do
  use Ash.Resource.Change
  alias TigerBeetlex.{Transfer, TransferFlags}
  alias Warui.Treasury.Helpers.TigerbeetleService
  alias Warui.Treasury.Helpers.TypeCache
  require Logger

  @doc """
  Voids a TigerBeetle pending transfer for a user.

  Options:
  * :currency - The currency code for the transfer (default: "KES")
  """
  def change(changeset, _opts, _context) do
    Ash.Changeset.before_transaction(changeset, &create_tigerbeetle_transfer/2)
  end

  defp create_tigerbeetle_transfer(changeset, {:ok, transfer}) do
    tenant = Ash.Changeset.get_argument(changeset, :tenant)

    transfer_type = TypeCache.get_transfer_type_by_id(transfer.transfer_type_id, tenant)
    ledger = TypeCache.get_ledger_asset_type_by_id(transfer.ledger_id, tenant)
    locale = Gettext.get_locale()

    tb_transfer = %Transfer{
      id: TigerbeetleService.uuidv7_to_128bit(transfer.id),
      user_data_128: TigerbeetleService.uuidv7_to_128bit(transfer.owner_id),
      user_data_64: TigerbeetleService.timestamp_to_user_data_64(),
      user_data_32: TigerbeetleService.get_locale_code(locale),
      ledger: ledger.code,
      code: transfer_type.code,
      flags: %TransferFlags{void_pending_transfer: true}
    }

    case TigerBeetlex.Connection.create_transfers(:tb, [tb_transfer]) do
      {:ok, _ref} ->
        Logger.info(
          "TigerBeetle transfer ensured for user #{transfer.owner_id} (idempotent operation succeeded)"
        )

        {:ok, transfer}

      {:error, reason} ->
        Logger.error("Failed to create TigerBeetle transfer: #{inspect(reason)}")
        {:ok, transfer}
    end
  end
end
