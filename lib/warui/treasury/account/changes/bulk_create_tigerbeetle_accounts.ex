defmodule Warui.Accounts.User.Changes.BulkCreateTigerBeetleAccounts do
  @moduledoc """
  Creates TigerBeetle accounts for users in bulk after the user resources are created.
  Handles tenant-specific accounts where tenant is passed as an argument.
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
      Ash.Changeset.after_transaction(changeset, &create_tigerbeetle_account/2)
    end)
  end

  defp create_tigerbeetle_account(changeset, {:ok, account}) do
    user = changeset.context.private.actor
    tenant = Ash.Changeset.get_argument(changeset, :tenant)
    flags = Ash.Changeset.get_argument(changeset, :flags) || %{}
    locale = Gettext.get_locale()

    attrs = %{
      id: account.id,
      ledger: account.account_ledger_id,
      code: account.account_type_id,
      user_data_128: account.account_owner_id,
      user_data_64: account.inserted_at,
      user_data_32: locale,
      flags: flags
    }

    case TigerbeetleService.create_account(attrs, user, tenant) do
      {:ok, _} -> {:ok, account}
      {:error, error} -> Ash.Changeset.add_error(changeset, error)
    end
  end
end
