defmodule Warui.Treasury.TigerbeetleTest do
  use WaruiWeb.ConnCase, async: false
  alias Warui.Treasury.Helpers.Seeder
  alias Warui.Treasury.Helpers.TypeCache
  alias Warui.Treasury.Helpers.TigerbeetleService

  # This setup assumes that you have a test TigerBeetle instance running
  # and that your test environment correctly initializes the TigerBeetle client

  describe "account operations" do
    test "create_account/1 creates an account" do
      user = create_user("John")

      Seeder.seed_treasury_types(user)
      TypeCache.init_caches(user)

      ledger = create_ledger("Cash", user.id)
      account = create_account("Checking", user.id, ledger.id)
      account_type_id = TypeCache.account_type_id("Checking", user)
      locale = get_user_locale()
      account_id = generate_uuid()

      attrs = %{
        id: account_id,
        ledger: ledger.id,
        code: account_type_id,
        user_data_128: account.account_owner_id,
        user_data_64: account.inserted_at,
        user_data_32: locale,
        flags: [:credits_must_not_exceed_debits]
      }

      assert {:ok, tb_account} = TigerbeetleService.create_account(attrs, user)
      assert tb_account.id == TigerbeetleService.uuidv7_to_128bit(account_id)
      assert account.account_ledger_id == ledger.id
      assert account.account_type_id == TypeCache.account_type_id("Checking", user)
    end

    test "get_account/1 retrieves an account" do
      user = create_user("John")
      Seeder.seed_treasury_types(user)
      TypeCache.init_caches(user)

      ledger = create_ledger("Cash", user.id)
      account = create_account("Checking", user.id, ledger.id)
      account_type_id = TypeCache.account_type_id("Checking", user)
      locale = get_user_locale()
      account_id = generate_uuid()

      {:ok, _account} =
        TigerbeetleService.create_account(
          %{
            id: account_id,
            ledger: ledger.id,
            code: account_type_id,
            user_data_128: account.account_owner_id,
            user_data_64: account.inserted_at,
            user_data_32: locale,
            flags: [:credits_must_not_exceed_debits]
          },
          user
        )

      # Then retrieve it
      assert {:ok, retrieved_account} = TigerbeetleService.get_account(account_id)
      assert retrieved_account.id == TigerbeetleService.uuidv7_to_128bit(account_id)
    end

    test "get_account_balance/1 returns the correct balance" do
      user1 = create_user("John")
      account1_id = generate_uuid()
      Seeder.seed_treasury_types(user1)
      TypeCache.init_caches(user1)
      ledger1 = create_ledger("Cash", user1.id)
      account1 = create_account("Checking", user1.id, ledger1.id)
      account1_type_id = TypeCache.account_type_id("Checking", user1)
      transfer_type_id = TypeCache.transfer_type_id("Payment", user1)

      user2 = create_user("Joe")
      account2_id = generate_uuid()
      Seeder.seed_treasury_types(user2)
      TypeCache.init_caches(user2)
      ledger2 = create_ledger("Cash", user2.id)
      ledger3 = create_ledger("Marketplace", user2.id)
      account2 = create_account("Checking", user2.id, ledger2.id)
      account2_type_id = TypeCache.account_type_id("Checking", user2)

      locale = get_user_locale()

      {:ok, _} =
        TigerbeetleService.create_account(
          %{
            id: account1_id,
            ledger: ledger1.id,
            code: account1_type_id,
            user_data_128: account1.account_owner_id,
            user_data_64: account1.inserted_at,
            user_data_32: locale,
            flags: [:credits_must_not_exceed_debits]
          },
          user1
        )

      {:ok, _} =
        TigerbeetleService.create_account(
          %{
            id: account2_id,
            ledger: ledger2.id,
            code: account2_type_id,
            user_data_128: account2.account_owner_id,
            user_data_64: account2.inserted_at,
            user_data_32: locale,
            flags: [:debits_must_not_exceed_credits]
          },
          user2
        )

      # Verify initial balances are zero
      assert {:ok, 0} = TigerbeetleService.get_account_balance(account1_id)
      assert {:ok, 0} = TigerbeetleService.get_account_balance(account2_id)

      # Create a transfer
      transfer_id = generate_uuid()
      inserted_at = get_current_datetime()

      {:ok, _} =
        TigerbeetleService.create_transfer(
          %{
            id: transfer_id,
            debit_account_id: account1_id,
            credit_account_id: account2_id,
            amount: 100,
            ledger: ledger3.id,
            code: transfer_type_id,
            user_data_128: user1.id,
            user_data_64: inserted_at,
            user_data_32: locale,
            flags: %{
              pending: false
            }
          },
          user1
        )

      # Verify balances after transfer
      assert {:ok, -100} = TigerbeetleService.get_account_balance(account1_id)
      assert {:ok, 100} = TigerbeetleService.get_account_balance(account2_id)
    end
  end

  # describe "transfer operations" do
  #   test "create_transfer/1 creates a transfer between accounts" do
  #     user1 = create_user("John")
  #     user2 = create_user("Joe")
  #
  #     # Create two accounts first
  #     account1_id = generate_uuid()
  #     account2_id = generate_uuid()
  #
  #     {:ok, _} =
  #       TigerbeetleService.create_account(
  #         %{
  #           id: account1_id,
  #           ledger: 1,
  #           code: 100
  #         },
  #         user1
  #       )
  #
  #     {:ok, _} =
  #       TigerbeetleService.create_account(
  #         %{
  #           id: account2_id,
  #           ledger: 1,
  #           code: 200
  #         },
  #         user2
  #       )
  #
  #     # Create a transfer between them
  #     transfer_id = generate_uuid()
  #
  #     assert {:ok, transfer} =
  #              TigerbeetleService.create_transfer(
  #                %{
  #                  id: transfer_id,
  #                  debit_account_id: account1_id,
  #                  credit_account_id: account2_id,
  #                  amount: 100,
  #                  ledger: 1,
  #                  code: 300
  #                },
  #                user1
  #              )
  #
  #     assert transfer.id == TigerbeetleService.uuidv7_to_128bit(transfer_id)
  #     assert transfer.amount == 100
  #   end
  #
  #   test "get_account_transfers/2 retrieves transfers for an account" do
  #     user1 = create_user("John")
  #     user2 = create_user("Joe")
  #     # Create two accounts
  #     account1_id = generate_uuid()
  #     account2_id = generate_uuid()
  #
  #     {:ok, _} =
  #       TigerbeetleService.create_account(
  #         %{
  #           id: account1_id,
  #           ledger: 1,
  #           code: 100
  #         },
  #         user1
  #       )
  #
  #     {:ok, _} =
  #       TigerbeetleService.create_account(
  #         %{
  #           id: account2_id,
  #           ledger: 1,
  #           code: 200
  #         },
  #         user2
  #       )
  #
  #     # Create multiple transfers
  #     transfer1_id = generate_uuid()
  #     transfer2_id = generate_uuid()
  #
  #     {:ok, _} =
  #       TigerbeetleService.create_transfer(
  #         %{
  #           id: transfer1_id,
  #           debit_account_id: account1_id,
  #           credit_account_id: account2_id,
  #           amount: 100,
  #           ledger: 1,
  #           code: 300
  #         },
  #         user1
  #       )
  #
  #     {:ok, _} =
  #       TigerbeetleService.create_transfer(
  #         %{
  #           id: transfer2_id,
  #           debit_account_id: account1_id,
  #           credit_account_id: account2_id,
  #           amount: 50,
  #           ledger: 1,
  #           code: 300
  #         },
  #         user1
  #       )
  #
  #     # Retrieve transfers for account1
  #     assert {:ok, transfers} = TigerbeetleService.get_account_transfers(account1_id)
  #     assert length(transfers) == 2
  #
  #     # Verify the transfers involve the correct account
  #     assert Enum.all?(transfers, fn transfer ->
  #              TigerbeetleService.uuidv7_to_128bit(account1_id) == transfer.debit_account_id
  #            end)
  #   end
  # end

  # Helper function to generate a UUID for testing
  defp generate_uuid do
    Ash.UUIDv7.generate()
  end

  defp get_user_locale do
    Gettext.get_locale()
  end

  defp get_current_datetime do
    DateTime.now!("Africa/Nairobi")
  end
end
