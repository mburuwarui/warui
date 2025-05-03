defmodule Warui.Treasury.TigerbeetleTest do
  use WaruiWeb.ConnCase, async: false
  alias Warui.Treasury.Helpers.TigerbeetleService
  use Warui.DataCase, async: false

  # This setup assumes that you have a test TigerBeetle instance running
  # and that your test environment correctly initializes the TigerBeetle client

  describe "account operations" do
    test "create_account/1 creates an account" do
      user1 = create_user("John")
      user2 = create_user("Joe")

      account_id = generate_uuid()

      attrs = %{
        id: account_id,
        ledger: 1,
        code: 100,
        flags: [:credits_must_not_exceed_debits]
      }

      assert {:ok, account} = TigerbeetleService.create_account(attrs, user1)
      assert account.id == TigerbeetleService.uuidv7_to_128bit(account_id)
      assert account.ledger == 1
      assert account.code == 100
    end

    test "get_account/1 retrieves an account" do
      # First create an account
      account_id = generate_uuid()

      {:ok, _account} =
        TigerbeetleService.create_account(
          %{
            id: account_id,
            ledger: 1,
            code: 100
          },
          user1
        )

      # Then retrieve it
      assert {:ok, retrieved_account} = TigerbeetleService.get_account(account_id)
      assert retrieved_account.id == TigerbeetleService.uuidv7_to_128bit(account_id)
    end

    test "get_account_balance/1 returns the correct balance" do
      # Create two accounts
      account1_id = generate_uuid()
      account2_id = generate_uuid()

      {:ok, _} =
        TigerbeetleService.create_account(
          %{
            id: account1_id,
            ledger: 1,
            code: 100
          },
          user1
        )

      {:ok, _} =
        TigerbeetleService.create_account(
          %{
            id: account2_id,
            ledger: 1,
            code: 200
          },
          user2
        )

      # Verify initial balances are zero
      assert {:ok, 0} = TigerbeetleService.get_account_balance(account1_id)
      assert {:ok, 0} = TigerbeetleService.get_account_balance(account2_id)

      # Create a transfer
      transfer_id = generate_uuid()

      {:ok, _} =
        TigerbeetleService.create_transfer(
          %{
            id: transfer_id,
            debit_account_id: account1_id,
            credit_account_id: account2_id,
            amount: 100,
            ledger: 1,
            code: 300
          },
          user1
        )

      # Verify balances after transfer
      assert {:ok, -100} = TigerbeetleService.get_account_balance(account1_id)
      assert {:ok, 100} = TigerbeetleService.get_account_balance(account2_id)
    end
  end

  describe "transfer operations" do
    test "create_transfer/1 creates a transfer between accounts" do
      # Create two accounts first
      account1_id = generate_uuid()
      account2_id = generate_uuid()

      {:ok, _} =
        TigerbeetleService.create_account(
          %{
            id: account1_id,
            ledger: 1,
            code: 100
          },
          user1
        )

      {:ok, _} =
        TigerbeetleService.create_account(
          %{
            id: account2_id,
            ledger: 1,
            code: 200
          },
          user2
        )

      # Create a transfer between them
      transfer_id = generate_uuid()

      assert {:ok, transfer} =
               TigerbeetleService.create_transfer(
                 %{
                   id: transfer_id,
                   debit_account_id: account1_id,
                   credit_account_id: account2_id,
                   amount: 100,
                   ledger: 1,
                   code: 300
                 },
                 user1
               )

      assert transfer.id == TigerbeetleService.uuidv7_to_128bit(transfer_id)
      assert transfer.amount == 100
    end

    test "get_account_transfers/2 retrieves transfers for an account" do
      # Create two accounts
      account1_id = generate_uuid()
      account2_id = generate_uuid()

      {:ok, _} =
        TigerbeetleService.create_account(
          %{
            id: account1_id,
            ledger: 1,
            code: 100
          },
          user1
        )

      {:ok, _} =
        TigerbeetleService.create_account(
          %{
            id: account2_id,
            ledger: 1,
            code: 200
          },
          user2
        )

      # Create multiple transfers
      transfer1_id = generate_uuid()
      transfer2_id = generate_uuid()

      {:ok, _} =
        TigerbeetleService.create_transfer(
          %{
            id: transfer1_id,
            debit_account_id: account1_id,
            credit_account_id: account2_id,
            amount: 100,
            ledger: 1,
            code: 300
          },
          user1
        )

      {:ok, _} =
        TigerbeetleService.create_transfer(
          %{
            id: transfer2_id,
            debit_account_id: account1_id,
            credit_account_id: account2_id,
            amount: 50,
            ledger: 1,
            code: 300
          },
          user1
        )

      # Retrieve transfers for account1
      assert {:ok, transfers} = TigerbeetleService.get_account_transfers(account1_id)
      assert length(transfers) == 2

      # Verify the transfers involve the correct account
      assert Enum.all?(transfers, fn transfer ->
               TigerbeetleService.uuidv7_to_128bit(account1_id) == transfer.debit_account_id
             end)
    end
  end

  # Helper function to generate a UUID for testing
  defp generate_uuid do
    Ash.UUIDv7.bingenerate()
  end
end
