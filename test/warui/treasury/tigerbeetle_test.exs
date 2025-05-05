defmodule Warui.Treasury.TigerbeetleTest do
  use WaruiWeb.ConnCase, async: false
  alias Warui.Treasury.Helpers.TypeCache
  alias Warui.Treasury.Helpers.TigerbeetleService

  # This setup assumes that you have a test TigerBeetle instance running
  # and that your test environment correctly initializes the TigerBeetle client

  describe "account operations" do
    test "create_account/1 creates an account" do
      user = create_user("John")

      ledger = create_ledger("Cash", user.id)
      account = create_account("Checking", user.id, ledger.id, user.current_organization)
      account_type_id = TypeCache.account_type_id("Checking", user)
      locale = get_user_locale()
      account_id = generate_uuid()

      # Create account
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

      # Build filter query
      filter = %{
        user_data_128: user.id,
        limit: 2
      }

      # retrieve query by user filter
      assert {:ok, query_result} = TigerbeetleService.query_accounts(filter, user)
      assert length(query_result) == 2

      assert tb_account.id == TigerbeetleService.uuidv7_to_128bit(account_id)
      assert account.account_ledger_id == ledger.id
      assert account.account_type_id == TypeCache.account_type_id("Checking", user)
    end

    test "get_account/1 retrieves an account" do
      user = create_user("Jane")

      ledger = create_ledger("Cash", user.id)
      account = create_account("Checking", user.id, ledger.id, user.current_organization)
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
      user1 = create_user("James")
      account1_id = generate_uuid()
      ledger1 = create_ledger("Cash", user1.id)
      account1 = create_account("Checking", user1.id, ledger1.id, user1.current_organization)
      account1_type_id = TypeCache.account_type_id("Checking", user1)
      transfer_type_id = TypeCache.transfer_type_id("Payment", user1)

      user2 = create_user("Joe")
      account2_id = generate_uuid()
      ledger2 = create_ledger("Cash", user2.id)
      ledger3 = create_ledger("Marketplace", user2.id)
      account2 = create_account("Checking", user2.id, ledger2.id, user2.current_organization)
      account2_type_id = TypeCache.account_type_id("Checking", user2)

      locale = get_user_locale()

      # Create accounts

      {:ok, _} =
        TigerbeetleService.create_account(
          %{
            id: account1_id,
            ledger: ledger1.id,
            code: account1_type_id,
            user_data_128: user1.id,
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
            user_data_128: user2.id,
            user_data_64: account2.inserted_at,
            user_data_32: locale,
            flags: [:debits_must_not_exceed_credits]
          },
          user2
        )

      # Then retrieve them
      assert {:ok, [tb_account1, tb_account2]} =
               TigerbeetleService.get_accounts([account1_id, account2_id])

      assert tb_account1.id == TigerbeetleService.uuidv7_to_128bit(account1_id)
      assert tb_account2.id == TigerbeetleService.uuidv7_to_128bit(account2_id)

      tb_timestamp_length =
        tb_account1.timestamp
        |> Integer.digits()
        |> length()

      current_time = get_current_datetime()
      five_minutes_ago = DateTime.add(current_time, -5 * 60, :second)
      five_minutes_later = DateTime.add(current_time, 5 * 60, :second)

      unix_five_minutes_ago = DateTime.to_unix(five_minutes_ago, :nanosecond)

      assert tb_timestamp_length ==
               unix_five_minutes_ago
               |> Integer.digits()
               |> length()

      # Build filter query
      filter = %{
        timestamp_min: five_minutes_ago,
        timestamp_max: five_minutes_later,
        limit: 2
      }

      # Query accounts by timestamp filter
      assert {:ok, query_result} = TigerbeetleService.query_accounts(filter, user1)

      assert length(query_result) == 2

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

  describe "transfer operations" do
    test "create_transfer/1 creates a transfer between accounts" do
      user1 = create_user("Janelle")
      account1_id = generate_uuid()
      ledger1 = create_ledger("Cash", user1.id)
      account1 = create_account("Checking", user1.id, ledger1.id, user1.current_organization)
      account1_type_id = TypeCache.account_type_id("Checking", user1)
      transfer_type_id = TypeCache.transfer_type_id("Payment", user1)

      user2 = create_user("Joe")
      account2_id = generate_uuid()
      ledger2 = create_ledger("Cash", user2.id)
      ledger3 = create_ledger("Marketplace", user2.id)
      account2 = create_account("Checking", user2.id, ledger2.id, user2.current_organization)
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

      {:ok, transfer} =
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

      # Then retrieve it
      assert {:ok, retrieved_transfer} = TigerbeetleService.get_transfer(transfer.id)

      assert retrieved_transfer.id == TigerbeetleService.uuidv7_to_128bit(transfer.id)
      assert transfer.amount == 100

      # Build filter query by locale
      filter = %{
        user_data_32: locale,
        limit: 2
      }

      assert {:ok, query_result} = TigerbeetleService.query_transfers(filter, user1)
      assert length(query_result) == 2

      # Build filter query by ledger
      filter = %{
        ledger: ledger1.id,
        limit: 2
      }

      assert {:ok, query_result} = TigerbeetleService.query_transfers(filter, user1)
      assert length(query_result) == 2

      # Build filter query by code
      filter = %{
        code: transfer_type_id,
        limit: 2
      }

      assert {:ok, query_result} = TigerbeetleService.query_transfers(filter, user1)
      assert length(query_result) == 2
    end

    test "get_account_transfers/2 retrieves transfers for an account" do
      user1 = create_user("Jimmy")
      account1_id = generate_uuid()
      ledger1 = create_ledger("Cash", user1.id)
      account1 = create_account("Checking", user1.id, ledger1.id, user1.current_organization)
      account1_type_id = TypeCache.account_type_id("Checking", user1)
      transfer_type_id = TypeCache.transfer_type_id("Payment", user1)

      user2 = create_user("Justin")
      account2_id = generate_uuid()
      ledger2 = create_ledger("Cash", user2.id)
      ledger3 = create_ledger("Marketplace", user2.id)
      account2 = create_account("Checking", user2.id, ledger2.id, user2.current_organization)
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
            flags: [:history, :credits_must_not_exceed_debits]
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
            flags: [:history, :debits_must_not_exceed_credits]
          },
          user2
        )

      # Verify initial balances are zero
      assert {:ok, 0} = TigerbeetleService.get_account_balance(account1_id)
      assert {:ok, 0} = TigerbeetleService.get_account_balance(account2_id)

      # Create multiple transfers
      transfer1_id = generate_uuid()
      transfer2_id = generate_uuid()
      inserted_at = get_current_datetime()

      {:ok, transfer1} =
        TigerbeetleService.create_transfer(
          %{
            id: transfer1_id,
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

      {:ok, transfer2} =
        TigerbeetleService.create_transfer(
          %{
            id: transfer2_id,
            debit_account_id: account1_id,
            credit_account_id: account2_id,
            amount: 50,
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

      {:ok, transfers_lookup} =
        TigerbeetleService.get_transfers([transfer1.id, transfer2.id])

      assert length(transfers_lookup) == 2

      # Build filter query for account1
      filter = %{
        account_id: account1_id,
        limit: 2,
        flags: %{
          debits: true
        }
      }

      # Retrieve transfers for account1
      assert {:ok, account1_transfers} = TigerbeetleService.get_account_transfers(filter)
      assert length(account1_transfers) == 2

      current_time = get_current_datetime()
      five_minutes_ago = DateTime.add(current_time, -5 * 60, :second)
      five_minutes_later = DateTime.add(current_time, 5 * 60, :second)

      unix_five_minutes_ago = DateTime.to_unix(five_minutes_ago, :nanosecond)
      unix_five_minutes_later = DateTime.to_unix(five_minutes_later, :nanosecond)

      # Extract the timestamp information for account1
      Enum.each(account1_transfers, fn transfer ->
        assert transfer.timestamp > unix_five_minutes_ago
        assert transfer.timestamp < unix_five_minutes_later
      end)

      # build filter query for account2 by code
      filter = %{
        account_id: account2_id,
        code: transfer_type_id,
        limit: 2,
        flags: %{
          credits: true
        }
      }

      # Retrieve transfers for account2
      # user actor required for code
      assert {:ok, account2_transfers} = TigerbeetleService.get_account_transfers(filter, user2)
      assert length(account2_transfers) == 2

      # Verify the transfers involve the correct account
      assert Enum.all?(account2_transfers, fn transfer ->
               TigerbeetleService.uuidv7_to_128bit(account1_id) == transfer.debit_account_id
             end)
    end
  end

  # Helper function to generate a UUID for testing
  defp generate_uuid do
    Ash.UUIDv7.generate()
  end

  defp get_user_locale do
    Gettext.get_locale()
  end

  defp get_current_datetime do
    DateTime.now!("Etc/UTC")
  end
end
