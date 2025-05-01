defmodule Warui.Accounts.User.Changes.CreateTigerBeetleAccount do
  use Ash.Resource.Change
  alias TigerBeetlex.{Account, AccountFlags}
  alias Warui.Treasury.Helpers.TigerbeetleService
  alias Warui.Treasury.Helpers.TypeCache
  require Logger

  @doc """
  Creates a TigerBeetle account for a user after the user resource is created.

  Options:
  * :currency - The currency code for the account (default: "KES")
  """
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_transaction(changeset, &create_tigerbeetle_account/2)
  end

  defp create_tigerbeetle_account(changeset, {:ok, account}) do
    user = changeset.context.private.actor

    asset_type_code = TypeCache.get_asset_type_code_by_name("Cash", user)
    account_type_code = TypeCache.get_account_type_code_by_name("Checking", user)

    # Get locale if it exists in the user record, otherwise default to "en_US"
    locale = Gettext.get_locale()

    tb_account = %Account{
      id: TigerbeetleService.uuidv7_to_128bit(account.id),
      user_data_128: TigerbeetleService.uuidv7_to_128bit(account.account_owner_id),
      user_data_64: TigerbeetleService.timestamp_to_user_data_64(),
      user_data_32: TigerbeetleService.get_locale_code(locale),
      ledger: asset_type_code,
      code: account_type_code,
      flags: %AccountFlags{history: true}
    }

    case TigerBeetlex.Connection.create_accounts(:tb, [tb_account]) do
      {:ok, _ref} ->
        Logger.info(
          "TigerBeetle account ensured for user #{account.account_owner_id} (idempotent operation succeeded)"
        )

        {:ok, account}

      {:error, reason} ->
        Logger.error("Failed to create TigerBeetle account: #{inspect(reason)}")
        {:ok, account}
    end
  end
end
