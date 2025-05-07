defmodule Warui.Accounts.User.Changes.BulkCreateTigerBeetleTenancyAccounts do
  @moduledoc """
  Creates TigerBeetle accounts for users in bulk after the user resources are created.
  Optimized for batch operations using Ash.Resource.Change batch callbacks.
  """
  use Ash.Resource.Change
  alias Warui.Treasury.Helpers.TigerbeetleService

  @doc """
  Sets up the after_transaction hook for single record changes.
  This will be called when not using bulk operations.

  Options:
  * :currency - The currency code for the account (default: "KES")
  """
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_transaction(changeset, &create_tigerbeetle_account/2)
  end

  @doc """
  Optimized batch change implementation.
  This will be called instead of change/3 when using bulk operations.
  """
  def batch_change(changesets, _opts, _context) do
    # Just set up the after_transaction hook - actual batching happens in after_batch
    Enum.map(changesets, fn changeset ->
      Ash.Changeset.after_transaction(changeset, &create_tigerbeetle_account/2)
    end)
  end

  @doc """
  Called after all records have been successfully created in the database.
  This is where we perform the bulk creation of TigerBeetle accounts.
  """
  def after_batch(results, _opts, _context) do
    # Filter successful results
    successful_results =
      results
      |> Enum.filter(fn {status, _changeset, _result} -> status == :ok end)

    # Extract changeset and created account from successful results
    account_data =
      successful_results
      |> Enum.map(fn {:ok, changeset, account} ->
        user = changeset.context.private.actor
        _tenant = user.current_organization
        flags = Ash.Changeset.get_argument(changeset, :flags)
        locale = Gettext.get_locale()

        %{
          id: account.id,
          ledger: account.account_ledger_id,
          code: account.account_type_id,
          user_data_128: account.account_owner_id,
          user_data_64: account.inserted_at,
          user_data_32: locale,
          flags: flags,
          # Include metadata needed for the result mapping
          _metadata: %{
            changeset: changeset,
            account: account
          }
        }
      end)

    # Skip if no successful results
    if Enum.empty?(account_data) do
      results
    else
      # Extract consistent user and tenant from the first record
      # (Assuming all records in a batch are for the same user/tenant)
      first_changeset = elem(hd(successful_results), 1)
      user = first_changeset.context.private.actor
      tenant = user.current_organization

      # Extract just the attributes for TigerBeetle
      attrs_list =
        Enum.map(account_data, fn data ->
          Map.drop(data, [:_metadata])
        end)

      # Call the bulk create function
      case TigerbeetleService.create_accounts(attrs_list, user, tenant) do
        {:ok, _accounts} ->
          # Return original results for successful operations
          results

        {:error, _errors} ->
          # Add errors to changesets for failed operations
          results
          |> Enum.map(fn
            {:ok, changeset, account} ->
              # Find matching account in our processed data
              matching_data =
                Enum.find(account_data, fn data ->
                  data._metadata.account.id == account.id
                end)

              # If there's a matching error for this account, add it to the changeset
              if matching_data do
                # Find corresponding error (in practice you'd need error mapping logic here)
                # This is simplified - you'd need proper error matching in real implementation
                {:error,
                 Ash.Changeset.add_error(changeset, "Failed to create TigerBeetle account")}
              else
                {:ok, changeset, account}
              end

            other ->
              # Pass through other results (already errors)
              other
          end)
      end
    end
  end

  # Handler for single account creation (used in non-batch mode)
  defp create_tigerbeetle_account(changeset, {:ok, account}) do
    user = changeset.context.private.actor
    tenant = user.current_organization
    flags = Ash.Changeset.get_argument(changeset, :flags)
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
      {:error, error} -> {:error, Ash.Changeset.add_error(changeset, error)}
    end
  end
end
