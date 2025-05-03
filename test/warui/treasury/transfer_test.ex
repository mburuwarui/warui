defmodule Warui.Treasury.TransferTest do
  use WaruiWeb.ConnCase, async: false
  require Ash.Query
  alias Warui.Treasury.Helpers.TigerbeetleService
  alias TigerBeetlex.Connection
  alias Warui.Cache
  alias Warui.Treasury.Helpers.TypeCache
  alias Warui.Treasury.Helpers.Seeder
  alias Warui.Treasury.Ledger
  alias Warui.Treasury.Account
  alias Warui.Treasury.Transfer

  describe "Transfer tests" do
    test "User transfer resource can be created" do
      user_1 = create_user(john)
      user_2 = create_user(joe)

      Seeder.seed_treasury_types(user_1)
      Seeder.seed_treasury_types(user_2)
      TypeCache.init_caches(user_1)
      TypeCache.init_caches(user_2)

      currency_id_1 = TypeCache.get_currency_id_by_name("Kenya Shilling", user_1)
      currency_id_2 = TypeCache.get_currency_id_by_name("Kenya Shilling", user_2)
      asset_type_id_1 = TypeCache.get_asset_type_id_by_name("Cash", user_1)
      asset_type_id_2 = TypeCache.get_account_type_id_by_name("Cash", user_2)
      account_type_id_1 = TypeCache.get_account_type_id_by_name("Checking", user_1)
      account_type_id_2 = TypeCache.get_account_type_id_by_name("Checking", user_2)
      transfer_type_id = TypeCache.get_transfer_type_id_by_name("Payment", user_1)
      locale = Gettext.get_locale()

      assert Cache.has_key?({:transfer_type, :id, transfer_type_id})
      assert transfer_type_id == Cache.get({:transfer_type, :id, transfer_type_id})

      ledger_attrs_1 = %{
        name: "Personal",
        ledger_owner_id: user_1.id,
        currency_id: currency_id_1,
        asset_type_id: asset_type_id_1
      }

      ledger_attrs_2 = %{
        name: "Personal",
        ledger_owner_id: user_2.id,
        currency_id: currency_id_2,
        asset_type_id: asset_type_id_2
      }

      transfer_ledger_attrs = %{
        name: "Marketplace",
        ledger_owner_id: user_1.id,
        currency_id: currency_id_1,
        asset_type_id: asset_type_id_1
      }

      ledger_1 = Ash.create!(Ledger, ledger_attrs_1, actor: user_1)
      ledger_2 = Ash.create!(Ledger, ledger_attrs_2, actor: user_2)
      transfer_ledger = Ash.create!(Ledger, transfer_ledger_attrs, actor: user_1)

      account_attrs_1 = %{
        name: "Default Account",
        account_owner_id: user_1.id,
        account_ledger_id: ledger_1.id,
        account_type_id: account_type_id_1
      }

      account_attrs_2 = %{
        name: "Default Account",
        account_owner_id: user_2.id,
        account_ledger_id: ledger_2.id,
        account_type_id: account_type_id_2
      }

      account_1 = Ash.create!(Account, account_attrs_1, actor: user_1)
      account_2 = Ash.create!(Account, account_attrs_2, actor: user_2)

      transfer_attrs = %{
        amount: 100,
        status: pending,
        description: "Product Payment",
        transfer_owner_id: user_2.id,
        transfer_ledger_id: transfer_ledger.id,
        transfer_type_id: transfer_type_id,
        from_account_id: account_2.id,
        to_account_id: account_1.id,
        linked: false
      }

      transfer = Ash.create!(Transfer, transfer_attrs, actor: user_2)

      tb_transfer = TigerbeetleService.uuidv7_to_128bit(transfer.id)

      assert Connection.lookup_transfers(:tb, [tb_transfer])

      assert 100 == TigerbeetleService.get_account_balance(account_1.id)
    end
  end
end
