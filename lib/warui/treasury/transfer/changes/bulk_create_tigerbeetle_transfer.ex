defmodule Warui.Treasury.Transfer.Changes.BulkCreateTigerbeetleTransfer do
  @moduledoc """
  Creates TigerBeetle transfers for users in bulk before the user resources are created.
  Optimized for batch operations using Ash.Resource.Change batch callbacks.
  """
  use Ash.Resource.Change
  alias Warui.Treasury.Helpers.TigerbeetleService

  @doc """
  Sets up the after_transaction hook for single record changes.
  This will be called when not using bulk operations.

  Options:
  * :tenant - The tenant identifier (required)
  * :flags - Account flags (optional)
  """

  def batch_change(changesets, _opts, _context) do
    Enum.map(changesets, fn changeset ->
      Ash.Changeset.before_transaction(changeset, &create_tigerbeetle_transfer/1)
    end)
  end

  defp create_tigerbeetle_transfer(changeset) do
    user = changeset.context.private.actor
    tenant = Ash.Changeset.get_argument(changeset, :tenant)
    flags = Ash.Changeset.get_argument(changeset, :flags) || %{}
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
      user_data_32: locale,
      flags: flags
    }

    case TigerbeetleService.create_transfer(attrs, user, tenant) do
      {:ok, _} -> changeset
      {:error, error} -> Ash.Changeset.add_error(changeset, error)
    end
  end
end
