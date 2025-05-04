defmodule Warui.Treasury.Transfer.Changes.VoidPendingTigerbeetleTransfer do
  use Ash.Resource.Change
  alias Warui.Treasury.Helpers.TigerbeetleService

  @doc """
  Voids a TigerBeetle pending transfer for a user.

  Options:
  * :currency - The currency code for the transfer (default: "KES")
  """
  def change(changeset, _opts, _context) do
    Ash.Changeset.before_transaction(changeset, &create_tigerbeetle_transfer/2)
  end

  defp create_tigerbeetle_transfer(changeset, {:ok, transfer}) do
    user = changeset.context.actor
    locale = Gettext.get_locale()

    attrs = %{
      id: transfer.id,
      user_data_128: transfer.transfer_owner_id,
      user_data_64: transfer.updated_at,
      user_data_32: locale,
      flags: %{
        void_pending_transfer: true
      }
    }

    TigerbeetleService.create_transfer(attrs, user)

    {:ok, transfer}
  end
end
