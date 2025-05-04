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
      user1 = create_user("John")
      user2 = create_user("Joe")

      Seeder.seed_treasury_types(user1)
      Seeder.seed_treasury_types(user2)
      TypeCache.init_caches(user1)
      TypeCache.init_caches(user2)

      currency_id1 = TypeCache.currency_id("Kenya Shilling", user1)
      currency_id2 = TypeCache.currency_id("Kenya Shilling", user2)
      asset_type_id1 = TypeCache.asset_type_id("Cash", user1)
      asset_type_id2 = TypeCache.asset_type_id("Cash", user2)
      account_type_id1 = TypeCache.account_type_id("Checking", user1)
      account_type_id2 = TypeCache.account_type_id("Checking", user2)
      transfer_type_id = TypeCache.transfer_type_id("Payment", user1)

      assert Cache.has_key?({:transfer_type, :id, transfer_type_id})
      assert transfer_type_id == Cache.get({:transfer_type, :id, transfer_type_id})

      ledger_attrs1 = %{
        name: "Personal",
        ledger_owner_id: user1.id,
        currency_id: currency_id1,
        asset_type_id: asset_type_id1
      }

      ledger_attrs2 = %{
        name: "Personal",
        ledger_owner_id: user2.id,
        currency_id: currency_id2,
        asset_type_id: asset_type_id2
      }

      transfer_ledger_attrs = %{
        name: "Marketplace",
        ledger_owner_id: user1.id,
        currency_id: currency_id1,
        asset_type_id: asset_type_id1
      }

      ledger1 = Ash.create!(Ledger, ledger_attrs1, actor: user1)
      ledger2 = Ash.create!(Ledger, ledger_attrs2, actor: user2)
      transfer_ledger = Ash.create!(Ledger, transfer_ledger_attrs, actor: user1)

      account_attrs1 = %{
        name: "Default Account",
        account_owner_id: user1.id,
        account_ledger_id: ledger1.id,
        account_type_id: account_type_id1
      }

      account_attrs2 = %{
        name: "Default Account",
        account_owner_id: user2.id,
        account_ledger_id: ledger2.id,
        account_type_id: account_type_id2
      }

      account1 = Ash.create!(Account, account_attrs1, actor: user1)
      account2 = Ash.create!(Account, account_attrs2, actor: user2)

      transfer_attrs = %{
        from_account_id: account2.id,
        to_account_id: account1.id,
        amount: 100,
        description: "Product Payment",
        transfer_owner_id: user2.id,
        transfer_ledger_id: transfer_ledger.id,
        transfer_type_id: transfer_type_id
      }

      transfer = Ash.create!(Transfer, transfer_attrs, actor: user2)

      tb_transfer = TigerbeetleService.uuidv7_to_128bit(transfer.id)

      assert Connection.lookup_transfers(:tb, [tb_transfer])

      assert 100 == TigerbeetleService.get_account_balance(account1.id)
    end
  end
end
