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
      account2 = create_account("Default Checking", user2.id, ledger2.id)
      transfer_ledger = create_ledger("Marketplace", user2.id)
      transfer_type_id = TypeCache.transfer_type_id("Payment", user2)
      transfer_tenant = user2.current_organization

      assert Cache.has_key?({:transfer_type, :id, {transfer_tenant, transfer_type_id}})

      assert transfer_type_id ==
               Cache.get({:transfer_type, :id, {transfer_tenant, transfer_type_id}}).id

      transfer_attrs = %{
        from_account_id: account2.id,
        to_account_id: account1.id,
        amount: Money.new!(:KES, 100),
        description: "Product Payment",
        transfer_owner_id: user2.id,
        transfer_ledger_id: transfer_ledger.id,
        transfer_type_id: transfer_type_id,
        tenant: transfer_tenant
      }

      transfer = Ash.create!(Transfer, transfer_attrs, actor: user2)

      tb_transfer = TigerbeetleService.uuidv7_to_128bit(transfer.id)

      assert Connection.lookup_transfers(:tb, [tb_transfer])

      assert 100 == TigerbeetleService.get_account_balance!(account1.id)
      assert 0 == TigerbeetleService.get_account_balance!(account2.id)
    end

    test "Bulk create transfers" do
      user1 = create_user("John")
      user2 = create_user("Jane")

      # marketplace domain
      market_owner = create_user("Joe")
      market_tenant = market_owner.current_organization
      market_ledger = create_ledger("Market", market_owner.id)
      market_transfer_type_id = TypeCache.transfer_type_id("Payment", market_owner)

      market_organization = TypeCache.organization_by_domain(market_owner.current_organization)

      # add users to market domain
      user_update =
        [
          %{
            user_id: user1.id,
            organization_id: market_organization.id
          },
          %{
            user_id: user2.id,
            organization_id: market_organization.id
          }
        ]
        |> Ash.bulk_create!(
          Warui.Accounts.UserOrganization,
          :add_users_to_organization,
          batch_size: 100,
          return_records?: true,
          return_errors?: true,
          actor: market_owner,
          tenant: market_tenant
        )

      assert length(user_update.records) == 2

      market_account_type_id = TypeCache.account_type_id("Business", market_owner)

      account1 =
        TypeCache.user_account(user1, market_ledger.id, market_account_type_id, market_tenant)

      account2 =
        TypeCache.user_account(user2, market_ledger.id, market_account_type_id, market_tenant)

      IO.inspect(user1.id, label: "User1 ID")
      IO.inspect(user2.id, label: "User1 ID")
      IO.inspect(market_account_type_id, label: "Market Account Type ID")
      IO.inspect(market_ledger.id, label: "Market Ledger ID")

      assert account1.account_ledger_id == market_ledger.id
      assert account2.account_ledger_id == market_ledger.id

      # Bulk create transfers 
      transfers =
        [
          %{
            from_account_id: account1.id,
            to_account_id: account2.id,
            amount: Money.new!(:KES, 100),
            description: "Product Payment",
            transfer_owner_id: user1.id,
            transfer_ledger_id: market_ledger.id,
            transfer_type_id: market_transfer_type_id,
            tenant: market_tenant,
            flags: %{
              debits_must_not_exceed_credits: true
            }
          },
          %{
            from_account_id: account2.id,
            to_account_id: account1.id,
            amount: Money.new!(:KES, 50),
            description: "Product Payment",
            transfer_owner_id: user2.id,
            transfer_ledger_id: market_ledger.id,
            transfer_type_id: market_transfer_type_id,
            tenant: market_tenant,
            flags: %{
              credits_must_not_exceed_debits: true
            }
          }
        ]
        |> Ash.bulk_create!(
          Transfer,
          :bulk_create_with_tigerbeetle_transfer,
          batch_size: 100,
          return_records?: true,
          return_errors?: true,
          actor: market_owner,
          tenant: market_tenant
        )

      assert length(transfers.records) == 2
      transfer2 = List.last(transfers.records)
      assert transfer2.from_account_id == account2.id
    end
  end
end
