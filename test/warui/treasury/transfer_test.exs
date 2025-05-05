defmodule Warui.Treasury.TransferTest do
  use WaruiWeb.ConnCase, async: false
  require Ash.Query
  alias Warui.Treasury.Helpers.TypeCache
  alias Warui.Treasury.Helpers.TigerbeetleService
  alias TigerBeetlex.Connection
  alias Warui.Cache

  alias Warui.Treasury.Transfer

  describe "Transfer tests" do
    test "User transfer resource can be created" do
      user1 = create_user("Jimmy")
      ledger1 = create_ledger("Personal", user1.id)
      account1 = create_account("Default Checking", user1.id, ledger1.id)

      user2 = create_user("Justin")
      ledger2 = create_ledger("Personal", user2.id)
      transfer_ledger = create_ledger("Marketplace", user2.id)
      account2 = create_account("Default Checking", user2.id, ledger2.id)
      transfer_type_id = TypeCache.transfer_type_id("Payment", user2)

      assert Cache.has_key?({:transfer_type, :id, transfer_type_id})
      assert transfer_type_id == Cache.get({:transfer_type, :id, transfer_type_id}).id

      transfer_amount = Money.new!(:KES, 100)

      transfer_attrs = %{
        from_account_id: account2.id,
        to_account_id: account1.id,
        amount: transfer_amount,
        description: "Product Payment",
        transfer_owner_id: user2.id,
        transfer_ledger_id: transfer_ledger.id,
        transfer_type_id: transfer_type_id
      }

      transfer = Ash.create!(Transfer, transfer_attrs, actor: user2)

      tb_transfer = TigerbeetleService.uuidv7_to_128bit(transfer.id)

      assert Connection.lookup_transfers(:tb, [tb_transfer])

      assert 100 == TigerbeetleService.get_account_balance!(account1.id)
      assert 0 == TigerbeetleService.get_account_balance!(account2.id)
    end
  end
end
