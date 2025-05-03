defmodule Warui.Treasury.Transfer.Changes.CreateTigerbeetleTransfer do
  use Ash.Resource.Change
  alias Warui.Treasury.Helpers.TigerbeetleService
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
    locale = Gettext.get_locale()

    transfer = %{
      id: transfer.id,
      debit_account_id: transfer.from_account_id,
      credit_account_id: transfer.to_account_id,
      amount: transfer.amount,
      ledger: transfer.transfer_ledger_id,
      code: transfer.transfer_type_id,
      user_data_128: transfer.transfer_owner_id,
      user_data_64: transfer.created_at,
      user_data_32: locale
    }

    TigerbeetleService.create_transfer(transfer, user)
  end
end
