defmodule Warui.Treasury.Transfer.Changes.CreateTigerbeetleTransfer do
  use Ash.Resource.Change
  alias Warui.Treasury.Helpers.TypeCache
  require Logger

  @doc """
  Creates a TigerBeetle transfer for a user when a transfer resource is created.

  Options:
  * :currency - The currency code for the transfer (default: "KES")
  """
  def change(changeset, _opts, _context) do
    Ash.Changeset.before_transaction(changeset, &create_tigerbeetle_transfer/2)
  end

  defp create_tigerbeetle_transfer(changeset, {:ok, transfer}) do
    user = changeset.context.actor
    :linked = Ash.Changeset.get_argument(changeset, :linked)
    from_account = TypeCache.get_account_by_id(transfer.from_account_id, user)
    to_account = TypeCache.get_account_by_id(transfer.to_account_id, user)
    locale = Gettext.get_locale()

    tb_transfer = %{
      id: transfer.id,
      debit_account_id: from_account.id,
      credit_account_id: to_account.id,
      amount: transfer.amount,
      ledger: transfer.transfer_ledger_id,
      code: transfer.transfer_type_id,
      user_data_128: transfer.transfer_owner_id,
      user_data_64: transfer.created_at,
      user_data_32: locale,
      timeout: 5,
      flags: [:linked]
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
