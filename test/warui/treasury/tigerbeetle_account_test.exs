defmodule Warui.Treasury.TigerbeetleAccountTest do
  use WaruiWeb.ConnCase, async: false
  require Ash.Query
  alias Warui.Cache
  alias Warui.Treasury.Helpers.TypeCache
  alias Warui.Treasury.Helpers.Seeder
  alias TigerBeetlex.{Account, AccountFlags}
  alias Warui.Treasury.Helpers.TigerbeetleService
  alias TigerBeetlex.Connection
  alias Warui.Treasury.Ledger
  alias Warui.Treasury.Account

  describe "Account tests" do
    test "User default tigerbeetle account can be created" do
      # create_user/0 is automatically imported from ConnCase
      user = create_user(john)

      Seeder.seed_treasury_types(user)
      TypeCache.init_caches(user)
      currency_id = TypeCache.get_currency_id_by_name("Kenya Shilling", user)
      asset_type_id = TypeCache.get_asset_type_id_by_name("Cash", user)
      asset_type_code = TypeCache.get_asset_type_code_by_name("Cash", user)
      account_type_id = TypeCache.get_account_type_id_by_name("Checking", user)
      account_type_code = TypeCache.get_account_type_code_by_name("Checking", user)

      assert Cache.has_key?({:currency, :id, currency_id})
      assert currency_id == Cache.get({:currency, :id, currency_id}).id

      ledger_attrs = %{
        name: "Personal",
        currency_id: currency_id,
        asset_type_id: asset_type_id,
        ledger_owner_id: user.id
      }

      ledger = Ash.create!(Ledger, ledger_attrs, actor: user)

      account_attrs = %{
        name: "Default Account",
        account_ledger_id: ledger.id,
        account_type_id: account_type_id,
        account_owner_id: user.id
      }

      account = Ash.create!(Account, account_attrs, actor: user)

      locale = Gettext.get_locale()

      tb_account = %Account{
        id: TigerbeetleService.uuidv7_to_128bit(account.id),
        user_data_128: TigerbeetleService.uuidv7_to_128bit(account.account_owner_id),
        user_data_64: TigerbeetleService.timestamp_to_user_data_64(),
        user_data_32: TigerbeetleService.get_locale_code(locale),
        ledger: asset_type_code,
        code: account_type_code,
        flags: %AccountFlags{history: true},
        timestamp: 0
      }

      Connection.create_accounts(:tb, [tb_account])

      # New account should be stored successfully
      assert Connection.lookup_accounts(:tb, [tb_account.id])
    end
  end
end
