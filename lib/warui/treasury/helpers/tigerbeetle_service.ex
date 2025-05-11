defmodule Warui.Treasury.Helpers.TigerbeetleService do
  @moduledoc """
  Service module to interact with TigerBeetle through the TigerBeetlex library.
  Provides simplified, application-focused functions for working with accounts and transfers.
  """

  alias TigerBeetlex.QueryFilterFlags
  alias TigerBeetlex.AccountFilterFlags
  alias Warui.Treasury.Helpers.MoneyConverter
  alias TigerBeetlex.Account
  alias TigerBeetlex.Transfer
  alias TigerBeetlex.AccountFilter
  alias TigerBeetlex.QueryFilter
  alias TigerBeetlex.AccountFlags
  alias TigerBeetlex.TransferFlags
  alias Warui.Treasury.Helpers.TypeCache

  def client do
    Application.get_env(:warui, :tigerbeetle_client) ||
      raise "TigerBeetle client not configured. Set it in your config with: config :your_app, :tigerbeetle_client, client"
  end

  @doc """
  Creates a new account in TigerBeetle.

  ## Parameters
    - attrs: Map of account attributes
    - user: User struct

  ## Returns
    - `{:ok, account}` on success
    - `{:error, reasons}` on failure, where reasons is a list of creation errors
  """
  def create_account(attrs, user, organization_owner) do
    account = %Account{
      id: uuidv7_to_128bit(attrs.id),
      ledger: TypeCache.ledger_asset_type_code(attrs.ledger, organization_owner),
      code: TypeCache.account_type_code(attrs.code, organization_owner),
      user_data_128: uuidv7_to_128bit(attrs.user_data_128) || <<0::128>>,
      user_data_64: DateTime.to_unix(attrs.user_data_64, :microsecond) || 0,
      user_data_32: TypeCache.locale_code(attrs.user_data_32, user) || 0,
      flags: build_account_flags(attrs[:flags] || %{})
    }

    case TigerBeetlex.Connection.create_accounts(client(), [account]) do
      {:ok, []} -> {:ok, account}
      {:ok, errors} -> {:error, errors}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Creates multiple accounts in TigerBeetle in a single batch.

  ## Parameters
    - accounts_attrs: List of maps containing account attributes

  ## Returns
    - `{:ok, accounts}` on success
    - `{:error, reasons}` on failure, where reasons is a list of creation errors
  """
  def create_accounts(accounts_attrs, user, organization_owner) do
    accounts =
      Enum.map(accounts_attrs, fn attrs ->
        %Account{
          id: uuidv7_to_128bit(attrs.id),
          ledger: TypeCache.ledger_asset_type_code(attrs.ledger, organization_owner),
          code: TypeCache.account_type_code(attrs.code, organization_owner),
          user_data_128: uuidv7_to_128bit(attrs.user_data_128) || <<0::128>>,
          user_data_64: DateTime.to_unix(attrs.user_data_64, :microsecond) || 0,
          user_data_32: TypeCache.locale_code(attrs.user_data_32, user) || 0,
          flags: build_account_flags(attrs[:flags] || %{})
        }
      end)

    case TigerBeetlex.Connection.create_accounts(client(), accounts) do
      {:ok, []} -> {:ok, accounts}
      {:ok, errors} -> {:error, errors}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Creates a transfer between two accounts.

  ## Parameters
    - attrs: Map of transfer attributes including:
      - id: Transfer ID
      - debit_account_id: ID of account to debit
      - credit_account_id: ID of account to credit
      - amount: Amount to transfer
      - ledger: Ledger ID
      - code: Transfer code
      - other optional attributes
    - user: User struct

  ## Returns
    - `{:ok, transfer}` on success
    - `{:error, reasons}` on failure, where reasons is a list of creation errors
  """
  def create_transfer(attrs, user, organization_owner) do
    transfer = %Transfer{
      id: uuidv7_to_128bit(attrs.id),
      debit_account_id: uuidv7_to_128bit(attrs.debit_account_id),
      credit_account_id: uuidv7_to_128bit(attrs.credit_account_id),
      amount: money_converter(attrs, user),
      ledger: TypeCache.ledger_asset_type_code(attrs.ledger, organization_owner),
      code: TypeCache.transfer_type_code(attrs.code, organization_owner),
      user_data_128: uuidv7_to_128bit(attrs.user_data_128) || <<0::128>>,
      user_data_64: DateTime.to_unix(attrs.user_data_64, :nanosecond) || 0,
      user_data_32: TypeCache.locale_code(attrs.user_data_32, user) || 0,
      flags: build_transfer_flags(attrs[:flags] || %{})
    }

    case TigerBeetlex.Connection.create_transfers(client(), [transfer]) do
      {:ok, []} -> {:ok, transfer}
      {:ok, errors} -> {:error, errors}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Creates multiple transfers in TigerBeetle in a single batch.

  ## Parameters
    - transfers_attrs: List of maps containing transfer attributes

  ## Returns
    - `{:ok, transfers}` on success
    - `{:error, reasons}` on failure, where reasons is a list of creation errors
  """
  def create_transfers(transfers_attrs, user, organization_owner) do
    transfers =
      Enum.map(transfers_attrs, fn attrs ->
        %Transfer{
          id: uuidv7_to_128bit(attrs.id),
          debit_account_id: uuidv7_to_128bit(attrs.debit_account_id),
          credit_account_id: uuidv7_to_128bit(attrs.credit_account_id),
          amount: money_converter(attrs, user),
          ledger: TypeCache.ledger_asset_type_code(attrs.ledger, organization_owner),
          code: TypeCache.transfer_type_code(attrs.code, organization_owner),
          user_data_128: uuidv7_to_128bit(attrs.user_data_128) || <<0::128>>,
          user_data_64: DateTime.to_unix(attrs.user_data_64, :nanosecond) || 0,
          user_data_32: TypeCache.locale_code(attrs.user_data_32, user) || 0,
          flags: build_transfer_flags(attrs[:flags] || %{})
        }
      end)

    case TigerBeetlex.Connection.create_transfers(client(), transfers) do
      {:ok, []} -> {:ok, transfers}
      {:ok, errors} -> {:error, errors}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Gets the current balance of an account.

  ## Parameters
    - account_id: ID of the account to check

  ## Returns
    - `{:ok, balance}` on success
    - `{:error, reason}` on failure
  """
  def get_account_balance(account_id) do
    tb_account_id = uuidv7_to_128bit(account_id)

    case TigerBeetlex.Connection.lookup_accounts(client(), [tb_account_id]) do
      {:ok, [account]} ->
        # Balance is credits - debits (accounting convention)
        balance = account.credits_posted - account.debits_posted
        {:ok, balance}

      {:ok, []} ->
        {:error, :account_not_found}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Gets the current balance of an account. Raises an error if the account is not found.

  ## Parameters
    - account_id: ID of the account to check

  ## Returns
    - Balance value on success
    - Raises an exception on failure
  """
  def get_account_balance!(account_id) do
    case get_account_balance(account_id) do
      {:ok, balance} -> balance
      {:error, reason} -> raise "Failed to get account balance: #{inspect(reason)}"
    end
  end

  @doc """
  Gets historical balance information for an account.
  Only available for accounts created with the `:history` flag.

  ## Parameters
    - account_id: ID of the account
    - limit: Maximum number of historical records to return

  ## Returns
    - `{:ok, account_balances}` on success
    - `{:error, reason}` on failure
  """
  def get_account_history(account_id, limit \\ 10) do
    tb_account_id = uuidv7_to_128bit(account_id)

    account_filter = %AccountFilter{
      account_id: tb_account_id,
      limit: limit
    }

    case TigerBeetlex.Connection.get_account_balances(client(), account_filter) do
      {:ok, account_balances} ->
        {:ok, account_balances}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Gets an account by its ID.

  ## Parameters
    - account_id: ID of the account to retrieve

  ## Returns
    - `{:ok, account}` on success
    - `{:error, :account_not_found}` if account doesn't exist
    - `{:error, reason}` on other failures
  """
  def get_account(account_id) do
    tb_account_id = uuidv7_to_128bit(account_id)

    case TigerBeetlex.Connection.lookup_accounts(client(), [tb_account_id]) do
      {:ok, [account]} -> {:ok, account}
      {:ok, []} -> {:error, :account_not_found}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Gets an account by its ID. Raises an error if the account is not found.

  ## Parameters
    - account_id: ID of the account to retrieve

  ## Returns
    - Account on success
    - Raises an exception on failure
  """
  def get_account!(account_id) do
    case get_account(account_id) do
      {:ok, account} -> account
      {:error, :account_not_found} -> raise "Account not found: #{account_id}"
      {:error, reason} -> raise "Failed to get account: #{inspect(reason)}"
    end
  end

  @doc """
  Gets multiple accounts by their IDs.

  ## Parameters
    - account_ids: List of account IDs to retrieve

  ## Returns
    - `{:ok, accounts}` on success (may contain fewer accounts than requested if some don't exist)
    - `{:error, reason}` on failure
  """
  def get_accounts(account_ids) do
    tb_account_ids = Enum.map(account_ids, &uuidv7_to_128bit/1)

    case TigerBeetlex.Connection.lookup_accounts(client(), tb_account_ids) do
      {:ok, accounts} -> {:ok, accounts}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Gets a transfer by its ID.

  ## Parameters
    - transfer_id: ID of the transfer to retrieve

  ## Returns
    - `{:ok, transfer}` on success
    - `{:error, :transfer_not_found}` if transfer doesn't exist
    - `{:error, reason}` on other failures
  """
  def get_transfer(transfer_id) do
    tb_transfer_id = uuidv7_to_128bit(transfer_id)

    case TigerBeetlex.Connection.lookup_transfers(client(), [tb_transfer_id]) do
      {:ok, [transfer]} -> {:ok, transfer}
      {:ok, []} -> {:error, :transfer_not_found}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Gets multiple transfers by their IDs.

  ## Parameters
    - transfer_ids: List of transfer IDs to retrieve

  ## Returns
    - `{:ok, transfers}` on success (may contain fewer transfers than requested if some don't exist)
    - `{:error, reason}` on failure
  """
  def get_transfers(transfer_ids) do
    tb_transfer_ids = Enum.map(transfer_ids, &uuidv7_to_128bit/1)

    case TigerBeetlex.Connection.lookup_transfers(client(), tb_transfer_ids) do
      {:ok, transfers} -> {:ok, transfers}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Gets all transfers involving a specific account.

  ## Parameters
    - account_id: ID of the account
    
    - user_data_128: Filter by user_data_128
    - user_data_64: Filter by user_data_64
    - user_data_32: Filter by user_data_32
    - code: Filter by transfer code
    - timestamp_min: transfers created before this timestamp
    - timestamp_max: transfers created after this timestamp
    - limit: Maximum number of transfers to return (required)
    - flags: transfers with these flags
      - debits: tranfers debited by account
      - credits: transfers credited by account
      - reversed: transfers in reverse order

  ## Returns
    - `{:ok, transfers}` on success
    - `{:error, reason}` on failure
  """
  def get_account_transfers(filter, user, organization_owner) do
    account_filter = %AccountFilter{
      account_id: (filter[:account_id] && uuidv7_to_128bit(filter[:account_id])) || <<0::128>>,
      user_data_128:
        (filter[:user_data_128] && uuidv7_to_128bit(filter[:user_data_128])) || <<0::128>>,
      user_data_64:
        (filter[:user_data_64] && DateTime.to_unix(filter[:user_data_64], :nanosecond)) || 0,
      user_data_32:
        (filter[:user_data_32] && TypeCache.locale_code(filter[:user_data_32], user)) || 0,
      code:
        (filter[:code] && TypeCache.transfer_type_code(filter[:code], organization_owner)) || 0,
      timestamp_min:
        (filter[:timestamp_min] && DateTime.to_unix(filter[:timestamp_min], :nanosecond)) || 0,
      timestamp_max:
        (filter[:timestamp_max] && DateTime.to_unix(filter[:timestamp_max], :nanosecond)) || 0,
      limit: filter[:limit] || 10,
      flags: build_account_filter_flags(filter[:flags] || %{})
    }

    case TigerBeetlex.Connection.get_account_transfers(client(), account_filter) do
      {:ok, transfers} -> {:ok, transfers}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Queries accounts by filter criteria.

  ## Parameters
    - filter: Map of filter criteria that can include:
      - ledger: Filter by ledger
      - code: Filter by account code
      - user_data_128: Filter by user_data_128
      - user_data_64: Filter by user_data_64
      - user_data_32: Filter by user_data_32
      - limit: Maximum number of accounts to return (required)
      - timestamp_min: Minimum timestamp
      - timestamp_max: Maximum timestamp

  ## Returns
    - `{:ok, accounts}` on success
    - `{:error, reason}` on failure
  """
  def query_accounts(filter, user, organization_owner) do
    query_filter = %QueryFilter{
      user_data_128:
        (filter[:user_data_128] && uuidv7_to_128bit(filter[:user_data_128])) || <<0::128>>,
      user_data_64:
        (filter[:user_data_64] && DateTime.to_unix(filter[:user_data_64], :nanosecond)) || 0,
      user_data_32:
        (filter[:user_data_32] && TypeCache.locale_code(filter[:user_data_32], user)) || 0,
      ledger:
        (filter[:ledger] && TypeCache.ledger_asset_type_code(filter[:ledger], organization_owner)) ||
          0,
      code:
        (filter[:code] && TypeCache.account_type_code(filter[:code], organization_owner)) || 0,
      timestamp_min:
        (filter[:timestamp_min] && DateTime.to_unix(filter[:timestamp_min], :nanosecond)) || 0,
      timestamp_max:
        (filter[:timestamp_max] && DateTime.to_unix(filter[:timestamp_max], :nanosecond)) || 0,
      limit: filter.limit || 10,
      flags: build_query_filter_flags(filter[:flags] || %{})
    }

    case TigerBeetlex.Connection.query_accounts(client(), query_filter) do
      {:ok, accounts} -> {:ok, accounts}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Queries transfers by filter criteria.

  ## Parameters
    - filter: Map of filter criteria that can include:
      - ledger: Filter by ledger
      - code: Filter by transfer code
      - user_data_128: Filter by user_data_128
      - user_data_64: Filter by user_data_64
      - user_data_32: Filter by user_data_32
      - limit: Maximum number of transfers to return (required)
      - timestamp_min: Minimum timestamp
      - timestamp_max: Maximum timestamp

  ## Returns
    - `{:ok, transfers}` on success
    - `{:error, reason}` on failure
  """
  def query_transfers(filter, user, organization_owner) do
    query_filter = %QueryFilter{
      user_data_128:
        (filter[:user_data_128] && uuidv7_to_128bit(filter[:user_data_128])) || <<0::128>>,
      user_data_64:
        (filter[:user_data_64] && DateTime.to_unix(filter[:user_data_64], :nanosecond)) || 0,
      user_data_32:
        (filter[:user_data_32] && TypeCache.locale_code(filter[:user_data_32], user)) || 0,
      ledger:
        (filter[:ledger] && TypeCache.ledger_asset_type_code(filter[:ledger], organization_owner)) ||
          0,
      code:
        (filter[:code] && TypeCache.transfer_type_code(filter[:code], organization_owner)) || 0,
      timestamp_min:
        (filter[:timestamp_min] && DateTime.to_unix(filter[:timestamp_min], :nanosecond)) || 0,
      timestamp_max:
        (filter[:timestamp_max] && DateTime.to_unix(filter[:timestamp_max], :nanosecond)) || 0,
      limit: filter.limit || 10,
      flags: build_query_filter_flags(filter[:flags] || %{})
    }

    case TigerBeetlex.Connection.query_transfers(client(), query_filter) do
      {:ok, transfers} -> {:ok, transfers}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Builds flags for an account from a map.

  Valid flags include: %{linked: true, debits_must_not_exceed_credits: true, 
  credits_must_not_exceed_debits: true, history: true, imported: true, closed: true}

  ## Examples

      iex> build_account_flags(%{linked: true, history: true})
      %AccountFlags{linked: true, history: true}
      
      iex> build_account_flags(%{})
      %AccountFlags{}
  """
  def build_account_flags(flags) when is_map(flags) do
    # Start with default struct (all flags set to false)
    valid_flags = [
      :linked,
      :debits_must_not_exceed_credits,
      :credits_must_not_exceed_debits,
      :history,
      :imported,
      :closed
    ]

    # Validate that all keys in the map are valid flags
    Enum.each(Map.keys(flags), fn key ->
      unless key in valid_flags do
        raise ArgumentError,
              "Invalid account flag: #{inspect(key)}. " <>
                "Valid flags are: #{inspect(valid_flags)}"
      end
    end)

    # Build the struct with provided values
    %AccountFlags{
      linked: Map.get(flags, :linked, false),
      debits_must_not_exceed_credits: Map.get(flags, :debits_must_not_exceed_credits, false),
      credits_must_not_exceed_debits: Map.get(flags, :credits_must_not_exceed_debits, false),
      history: Map.get(flags, :history, false),
      imported: Map.get(flags, :imported, false),
      closed: Map.get(flags, :closed, false)
    }
  end

  # For backward compatibility, keep the list version but convert to map
  def build_account_flags(flags) when is_list(flags) do
    flags
    |> Enum.map(fn flag -> {flag, true} end)
    |> Map.new()
    |> build_account_flags()
  end

  @doc """
  Builds flags for a transfer from a map.

  Valid flags include: %{linked: true, pending: true, post_pending_transfer: true, void_pending_transfer: true, 
  balancing_debit: true, balancing_credit: true, closing_debit: true, closing_credit: true, imported: true}

  ## Examples

      iex> build_transfer_flags(%{linked: true, post_pending_transfer: true})
      %TransferFlags{linked: true, post_pending_transfer: true}
      
      iex> build_transfer_flags(%{})
      %TransferFlags{}
  """
  def build_transfer_flags(flags) when is_map(flags) do
    # Start with default struct (all flags set to false)
    valid_flags = [
      :linked,
      :pending,
      :post_pending_transfer,
      :void_pending_transfer,
      :balancing_debit,
      :balancing_credit,
      :closing_debit,
      :closing_credit,
      :imported
    ]

    # Validate that all keys in the map are valid flags
    Enum.each(Map.keys(flags), fn key ->
      unless key in valid_flags do
        raise ArgumentError,
              "Invalid transfer flag: #{inspect(key)}. " <>
                "Valid flags are: #{inspect(valid_flags)}"
      end
    end)

    # Build the struct with provided values
    %TransferFlags{
      linked: Map.get(flags, :linked, false),
      pending: Map.get(flags, :pending, false),
      post_pending_transfer: Map.get(flags, :post_pending_transfer, false),
      void_pending_transfer: Map.get(flags, :void_pending_transfer, false),
      balancing_debit: Map.get(flags, :balancing_debit, false),
      balancing_credit: Map.get(flags, :balancing_credit, false),
      closing_debit: Map.get(flags, :closing_debit, false),
      closing_credit: Map.get(flags, :closing_credit, false),
      imported: Map.get(flags, :imported, false)
    }
  end

  # For backward compatibility, keep the list version but convert to map
  def build_transfer_flags(flags) when is_list(flags) do
    flags
    |> Enum.map(fn flag -> {flag, true} end)
    |> Map.new()
    |> build_transfer_flags()
  end

  def build_account_filter_flags(flags) when is_map(flags) do
    # Start with default struct (all flags set to false)
    valid_flags = [
      :debits,
      :credits,
      :reversed
    ]

    # Validate that all keys in the map are valid flags
    Enum.each(Map.keys(flags), fn key ->
      unless key in valid_flags do
        raise ArgumentError,
              "Invalid account filter flag: #{inspect(key)}. " <>
                "Valid flags are: #{inspect(valid_flags)}"
      end
    end)

    # Build the struct with provided values
    %AccountFilterFlags{
      debits: Map.get(flags, :debits, false),
      credits: Map.get(flags, :credits, false),
      reversed: Map.get(flags, :reversed, false)
    }
  end

  # For backward compatibility, keep the list version but convert to map
  def build_account_filter_flags(flags) when is_list(flags) do
    flags
    |> Enum.map(fn flag -> {flag, true} end)
    |> Map.new()
    |> build_account_filter_flags()
  end

  def build_query_filter_flags(flags) when is_map(flags) do
    # Start with default struct (all flags set to false)
    valid_flags = [
      :reversed
    ]

    # Validate that all keys in the map are valid flags
    Enum.each(Map.keys(flags), fn key ->
      unless key in valid_flags do
        raise ArgumentError,
              "Invalid query filter flag: #{inspect(key)}. " <>
                "Valid flags are: #{inspect(valid_flags)}"
      end
    end)

    # Build the struct with provided values
    %QueryFilterFlags{
      reversed: Map.get(flags, :reversed, false)
    }
  end

  def build_query_filter_flags(flags) when is_list(flags) do
    flags
    |> Enum.map(fn flag -> {flag, true} end)
    |> Map.new()
    |> build_query_filter_flags()
  end

  def money_converter(attrs, user) do
    # Convert Money amount to TigerBeetle integer with appropriate asset scale
    case attrs.amount do
      %Money{} = money ->
        # Get the currency from the Money struct
        currency = money.currency

        # Get the asset scale that should be used for this currency in TigerBeetle
        # This could be based on the ledger configuration
        asset_scale =
          TypeCache.ledger_asset_scale(attrs.ledger, user) ||
            MoneyConverter.get_asset_scale_for_currency(currency)

        # Convert the money to a TigerBeetle amount using the appropriate asset scale
        MoneyConverter.money_to_tigerbeetle_amount(money, asset_scale)

      integer when is_integer(integer) and integer >= 0 ->
        # If it's already an integer, we assume it's already in the right scale
        integer

      other ->
        raise ArgumentError,
              "Expected Money struct or non-negative integer for amount, got: #{inspect(other)}"
    end
  end

  @doc """
   Converts a UUID v7 string to a 128-bit binary ID for TigerBeetle.
  """
  def uuidv7_to_128bit(uuidv7) do
    Ash.UUIDv7.decode(uuidv7)
  end

  # # Converts user_data_64 and user_data_32 to integers
  # defp convert_user_data(attrs) when is_integer(attrs), do: attrs
  #
  # defp convert_user_data(attrs) when is_binary(attrs) do
  #   String.to_integer(attrs)
  # end
  #
  # defp convert_user_data(%{user_data_64: attrs}), do: convert_user_data(attrs)
  # defp convert_user_data(%{user_data_32: attrs}), do: convert_user_data(attrs)
  #
  # defp convert_user_data(attrs) when is_map(attrs) do
  #   convert_user_data(Map.get(attrs, :user_data_64)) ||
  #     convert_user_data(Map.get(attrs, :user_data_32))
  # end

  # Extract timestamp for user_data_64
  def timestamp_now do
    System.system_time(:millisecond)
  end
end
