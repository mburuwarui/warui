defmodule Warui.Treasury.TransferTest do
  use WaruiWeb.ConnCase, async: false
  require Ash.Query
  alias Warui.Treasury.Helpers.MoneyConverter
  alias Warui.Treasury.Helpers.TypeCache
  alias Warui.Treasury.Helpers.TigerbeetleService
  alias TigerBeetlex.Connection
  alias Warui.Cache
  alias Warui.Treasury.Transfer

  describe "Transfer tests" do
    test "User transfer resource can be created" do
      user1 = create_user()
      user2 = create_user()

      # marketplace domain
      organization_owner = create_user()
      tenant = organization_owner.current_organization
      market_ledger = create_ledger("Market", organization_owner.id)
      market_transfer_type_id = TypeCache.transfer_type_id("Payment", organization_owner)

      market_organization =
        TypeCache.organization_by_domain(organization_owner.current_organization)

      assert Cache.has_key?(
               {:transfer_type, :id,
                {organization_owner.current_organization, market_transfer_type_id}}
             )

      assert market_transfer_type_id ==
               Cache.get(
                 {:transfer_type, :id,
                  {organization_owner.current_organization, market_transfer_type_id}}
               ).id

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
          actor: organization_owner,
          tenant: tenant
        )

      assert length(user_update.records) == 2

      business_account_type_id = TypeCache.account_type_id("Business", organization_owner)
      merchant_account_type_id = TypeCache.account_type_id("Merchant", organization_owner)
      merchant_ledger = TypeCache.ledger_by_name("Shop", user2, organization_owner)

      account1 =
        TypeCache.user_account(
          user1,
          market_ledger.id,
          business_account_type_id,
          organization_owner
        )

      account2 =
        TypeCache.user_account(
          user2,
          merchant_ledger.id,
          merchant_account_type_id,
          organization_owner
        )

      assert account1.account_ledger_id == market_ledger.id
      assert account2.account_ledger_id == merchant_ledger.id

      transfer_attrs = %{
        from_account_id: account1.id,
        to_account_id: account2.id,
        amount: Money.new!(:KES, 100),
        description: "Product Payment",
        transfer_owner_id: user1.id,
        transfer_ledger_id: market_ledger.id,
        transfer_type_id: market_transfer_type_id,
        organization_owner: organization_owner
      }

      transfer =
        Transfer
        |> Ash.Changeset.for_create(:create, transfer_attrs, actor: organization_owner)
        |> Ash.create!()

      tb_transfer_id = TigerbeetleService.uuidv7_to_128bit(transfer.id)

      {:ok, transfers} = Connection.lookup_transfers(:tb, [tb_transfer_id])
      assert length(transfers) == 1

      assert -10000 == TigerbeetleService.get_account_balance!(account1.id)
      assert 10000 == TigerbeetleService.get_account_balance!(account2.id)

      assert Money.new(:KES, "100.00") ==
               TigerbeetleService.get_account_balance!(account2.id)
               |> MoneyConverter.tigerbeetle_amount_to_money(:KES, 2)
    end

    test "Bulk create transfers" do
      user1 = create_user()
      user2 = create_user()

      # marketplace domain
      organization_owner = create_user()
      tenant = organization_owner.current_organization
      market_ledger = create_ledger("Market", organization_owner.id)
      market_transfer_type_id = TypeCache.transfer_type_id("Payment", organization_owner)

      market_organization =
        TypeCache.organization_by_domain(organization_owner.current_organization)

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
          actor: organization_owner,
          tenant: tenant
        )

      assert length(user_update.records) == 2

      business_account_type_id = TypeCache.account_type_id("Business", organization_owner)
      merchant_account_type_id = TypeCache.account_type_id("Merchant", organization_owner)
      merchant_ledger = TypeCache.ledger_by_name("Shop", user2, organization_owner)

      account1 =
        TypeCache.user_account(
          user1,
          market_ledger.id,
          business_account_type_id,
          organization_owner
        )

      account2 =
        TypeCache.user_account(
          user2,
          merchant_ledger.id,
          merchant_account_type_id,
          organization_owner
        )

      assert account1.account_ledger_id == market_ledger.id
      assert account2.account_ledger_id == merchant_ledger.id

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
            organization_owner: organization_owner
          },
          %{
            from_account_id: account2.id,
            to_account_id: account1.id,
            amount: Money.new!(:KES, 50),
            description: "Product Payment",
            transfer_owner_id: user2.id,
            transfer_ledger_id: market_ledger.id,
            transfer_type_id: market_transfer_type_id,
            organization_owner: organization_owner
          }
        ]
        |> Ash.bulk_create!(
          Transfer,
          :bulk_create_with_tigerbeetle_transfer,
          batch_size: 100,
          return_records?: true,
          return_errors?: true,
          actor: organization_owner,
          tenant: tenant
        )

      assert length(transfers.records) == 2
      transfer2 = List.last(transfers.records)
      assert transfer2.from_account_id == account1.id

      {:ok, transfer} = TigerbeetleService.get_transfer(transfer2.id)

      assert transfer.debit_account_id == TigerbeetleService.uuidv7_to_128bit(account1.id)
    end
  end
end
