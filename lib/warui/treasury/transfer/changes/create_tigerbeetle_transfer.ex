defmodule Warui.Treasury.Transfer.Changes.CreateTigerbeetleTransfer do
  use Ash.Resource.Change
  alias Warui.Treasury.Helpers.TigerbeetleService

  @doc """
  Creates a TigerBeetle transfer for a user when a transfer resource is created.

  Options:
  * :currency - The currency code for the transfer (default: "KES")
  """
  def change(changeset, _opts, _context) do
    Ash.Changeset.before_transaction(changeset, &create_tigerbeetle_transfer/1)
  end

  defp create_tigerbeetle_transfer(changeset) do
    user = changeset.context.private.actor
    locale = Gettext.get_locale()

    attrs = %{
      id: changeset.attributes.id,
      debit_account_id: changeset.attributes.from_account_id,
      credit_account_id: changeset.attributes.to_account_id,
      amount: changeset.attributes.amount,
      ledger: changeset.attributes.transfer_ledger_id,
      code: changeset.attributes.transfer_type_id,
      user_data_128: changeset.attributes.transfer_owner_id,
      user_data_64: changeset.attributes.inserted_at,
      user_data_32: locale
    }

    case TigerbeetleService.create_transfer(attrs, user) do
      {:ok, _} -> changeset
      {:error, error} -> Ash.Changeset.add_error(changeset, error)
    end
  end
end
