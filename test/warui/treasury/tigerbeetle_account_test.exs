defmodule Warui.Treasury.TigerbeetleAccountTest do
  use WaruiWeb.ConnCase, async: false
  require Ash.Query
  alias Warui.Cache
  alias Warui.Treasury.Helpers.TypeCache
  alias Warui.Treasury.Helpers.Seeder
  alias TigerBeetlex.{Account, AccountFlags}
  alias Warui.Treasury.Helpers.TigerbeetleService

  describe "Account tests" do
    test "User default tigerbeetle account can be created" do
      # create_user/0 is automatically imported from ConnCase
      user = create_user()

      # Create a new team for the user
      organization_attrs = %{name: "Org 1", domain: "org_1", owner_user_id: user.id}
      {:ok, _organization} = Ash.create(Warui.Accounts.Organization, organization_attrs)

      Seeder.seed_treasury_types(user)
      currency = TypeCache.get_currency_by_name("Kenya Shilling", user)
      asset_type = TypeCache.get_asset_type_by_name("Cash", user)
      account_type = TypeCache.get_account_type_by_name("Checking", user)

      assert Cache.has_key?({:currency, :name, currency.name})
      assert currency == Cache.get({:currency, :name, currency.name})

      ledger_attrs = %{
        name: "Personal",
        currency_id: currency.id,
        asset_type_id: asset_type.id,
        ledger_owner_id: user.id
      }

      ledger = Ash.create!(Warui.Treasury.Ledger, ledger_attrs, actor: user)

      account_attrs = %{
        name: "Default Account",
        account_ledger_id: ledger.id,
        account_type_id: account_type.id
      }

      account = Ash.create!(Warui.Treasury.Account, account_attrs, actor: user)

      locale = Gettext.get_locale()

      tb_account = %Account{
        id: TigerbeetleService.uuidv7_to_128bit(account.id),
        user_data_128: TigerbeetleService.uuidv7_to_128bit(account.account_owner_id),
        user_data_64: TigerbeetleService.timestamp_to_user_data_64(),
        user_data_32: TigerbeetleService.get_locale_code(locale),
        ledger: asset_type.code,
        code: account_type.code,
        flags: %AccountFlags{history: true},
        timestamp: 0
      }

      TigerBeetlex.Connection.create_accounts(:tb, [tb_account])

      # New account should be stored successfully
      assert TigerBeetlex.Connection.lookup_accounts(:tb, [tb_account.id])
    end
  end
end
