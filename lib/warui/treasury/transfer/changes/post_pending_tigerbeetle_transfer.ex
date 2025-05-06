defmodule Warui.Treasury.Transfer.Changes.PostPendingTigerbeetleTransfer do
  use Ash.Resource.Change
  alias Warui.Treasury.Helpers.TigerbeetleService

  @doc """
  Posts a TigerBeetle pending transfer for a user.

  Options:
  * :currency - The currency code for the transfer (default: "KES")
  """
  def change(changeset, _opts, _context) do
    Ash.Changeset.before_transaction(changeset, &create_tigerbeetle_transfer/1)
  end

  defp create_tigerbeetle_transfer(changeset) do
    user = changeset.context.private.actor

    tenant = Ash.Changeset.get_argument(changeset, :tenant)

    locale = Gettext.get_locale()

    attrs = %{
      id: changeset.attributes.id,
      user_data_128: changeset.attributes.transfer_owner_id,
      user_data_64: changeset.attributes.inserted_at,
      user_data_32: locale,
      flags: %{
        post_pending_transfer: true
      }
    }

    case TigerbeetleService.create_transfer(attrs, user, tenant) do
      {:ok, _} -> changeset
      {:error, error} -> Ash.Changeset.add_error(changeset, error)
    end
  end
end
