defmodule Warui.Treasury.Helpers.TigerbeetleService do
  @moduledoc """
  Service module to interact with TigerBeetle through the TigerBeetlex library.
  Provides simplified, application-focused functions for working with accounts and transfers.
  """

  alias Warui.Treasury.Helpers.MoneyConverter
  alias TigerBeetlex.Account
  alias TigerBeetlex.Transfer
  alias TigerBeetlex.AccountFilter
  alias TigerBeetlex.QueryFilter
  alias TigerBeetlex.AccountFlags
  alias TigerBeetlex.TransferFlags
  alias Warui.Treasury.Helpers.TypeCache

  @locale_codes %{
    "en" => 1,
    "en_GB" => 2,
    "en_KE" => 3,
    "fr_FR" => 4,
    "de_DE" => 5
  }

  def client do
    Application.get_env(:warui, :tigerbeetle_client) ||
      raise "TigerBeetle client not configured. Set it in your config with: config :your_app, :tigerbeetle_client, client"
  end

  @doc """
  Creates a new account in TigerBeetle.

  ## Parameters
    - attrs: Map of account attributes

  ## Returns
    - `{:ok, account}` on success
    - `{:error, reasons}` on failure, where reasons is a list of creation errors
  """
  def create_account(attrs) do
    account = %Account{
      id: uuidv7_to_128bit(attrs.id),
      ledger: attrs.ledger,
      code: attrs.code,
      user_data_128: attrs[:user_data_128] || <<0::128>>,
      user_data_64: attrs[:user_data_64] || 0,
      user_data_32: attrs[:user_data_32] || 0,
      flags: build_account_flags(attrs[:flags] || []),
      timestamp: attrs[:timestamp] || 0
    }

    case TigerBeetlex.create_accounts(client(), [account]) do
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
  def create_accounts(accounts_attrs, user) do
    accounts =
      Enum.map(accounts_attrs, fn attrs ->
        %Account{
          id: uuidv7_to_128bit(attrs.id),
          ledger: TypeCache.get_ledger_asset_type_by_id(attrs.ledger, user),
          code: TypeCache.get_transfer_type_by_id(attrs.code, user),
          user_data_128: uuidv7_to_128bit(attrs.user_data_128) || <<0::128>>,
          user_data_64: DateTime.to_unix(attrs.user_data_64, :milliseconds) || 0,
          user_data_32: get_locale_code(attrs.user_data_32) || 0,
          flags: build_account_flags(attrs[:flags] || []),
          timestamp: timestamp_now()
        }
      end)

    case TigerBeetlex.create_accounts(client(), accounts) do
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

  ## Returns
    - `{:ok, transfer}` on success
    - `{:error, reasons}` on failure, where reasons is a list of creation errors
  """
  def create_transfer(attrs, user) do
    transfer = %Transfer{
      id: uuidv7_to_128bit(attrs.id),
      debit_account_id: uuidv7_to_128bit(attrs.debit_account_id),
      credit_account_id: uuidv7_to_128bit(attrs.credit_account_id),
      amount: money_converter(attrs, user),
      ledger: TypeCache.get_ledger_asset_type_by_id(attrs.ledger, user),
      code: TypeCache.get_transfer_type_by_id(attrs.code, user),
      user_data_128: uuidv7_to_128bit(attrs.user_data_128) || <<0::128>>,
      user_data_64: DateTime.to_unix(attrs.user_data_64, :milliseconds) || 0,
      user_data_32: get_locale_code(attrs.user_data_32) || 0,
      timeout: Decimal.to_integer(attrs.timeout) || 0,
      flags: build_transfer_flags(attrs[:flags] || []),
      timestamp: timestamp_now()
    }

    case TigerBeetlex.create_transfers(client(), [transfer]) do
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
  def create_transfers(transfers_attrs) do
    transfers =
      Enum.map(transfers_attrs, fn attrs ->
        %Transfer{
          id: uuidv7_to_128bit(attrs.id),
          debit_account_id: uuidv7_to_128bit(attrs.debit_account_id),
          credit_account_id: uuidv7_to_128bit(attrs.credit_account_id),
          amount: attrs.amount,
          ledger: attrs.ledger,
          code: attrs.code,
          user_data_128: attrs[:user_data_128] || <<0::128>>,
          user_data_64: attrs[:user_data_64] || 0,
          user_data_32: attrs[:user_data_32] || 0,
          timeout: attrs[:timeout] || 0,
          flags: build_transfer_flags(attrs[:flags] || []),
          timestamp: attrs[:timestamp] || 0
        }
      end)

    case TigerBeetlex.create_transfers(client(), transfers) do
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

    case TigerBeetlex.lookup_accounts(client(), [tb_account_id]) do
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

    case TigerBeetlex.get_account_balances(client(), account_filter) do
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

    case TigerBeetlex.lookup_accounts(client(), [tb_account_id]) do
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

    case TigerBeetlex.lookup_accounts(client(), tb_account_ids) do
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

    case TigerBeetlex.lookup_transfers(client(), [tb_transfer_id]) do
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

    case TigerBeetlex.lookup_transfers(client(), tb_transfer_ids) do
      {:ok, transfers} -> {:ok, transfers}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Gets all transfers involving a specific account.

  ## Parameters
    - account_id: ID of the account
    - limit: Maximum number of transfers to return

  ## Returns
    - `{:ok, transfers}` on success
    - `{:error, reason}` on failure
  """
  def get_account_transfers(account_id, limit \\ 10) do
    tb_account_id = uuidv7_to_128bit(account_id)

    account_filter = %AccountFilter{
      account_id: tb_account_id,
      limit: limit
    }

    case TigerBeetlex.get_account_transfers(client(), account_filter) do
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
  def query_accounts(filter) do
    query_filter = %QueryFilter{
      ledger: filter[:ledger],
      code: filter[:code],
      user_data_128: filter[:user_data_128],
      user_data_64: filter[:user_data_64],
      user_data_32: filter[:user_data_32],
      limit: filter.limit,
      timestamp_min: filter[:timestamp_min] || 0,
      timestamp_max: filter[:timestamp_max] || 0
    }

    case TigerBeetlex.query_accounts(client(), query_filter) do
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
  def query_transfers(filter) do
    query_filter = %QueryFilter{
      ledger: filter[:ledger],
      code: filter[:code],
      user_data_128: filter[:user_data_128],
      user_data_64: filter[:user_data_64],
      user_data_32: filter[:user_data_32],
      limit: filter.limit,
      timestamp_min: filter[:timestamp_min] || 0,
      timestamp_max: filter[:timestamp_max] || 0
    }

    case TigerBeetlex.query_transfers(client(), query_filter) do
      {:ok, transfers} -> {:ok, transfers}
      {:error, reason} -> {:error, reason}
    end
  end

  @doc """
  Builds flags for an account from a list of atoms.

  Valid flags include: [:linked, :debits_must_not_exceed_credits, :credits_must_not_exceed_debits, :history]

  ## Examples

      iex> build_account_flags([:linked, :history])
      %AccountFlags{linked: true, history: true}
      
      iex> build_account_flags([])
      %AccountFlags{}
  """
  def build_account_flags(flags) when is_list(flags) do
    # Start with default struct (all flags set to false)
    Enum.reduce(flags, %AccountFlags{}, fn flag, acc ->
      case flag do
        :linked ->
          %{acc | linked: true}

        :debits_must_not_exceed_credits ->
          %{acc | debits_must_not_exceed_credits: true}

        :credits_must_not_exceed_debits ->
          %{acc | credits_must_not_exceed_debits: true}

        :history ->
          %{acc | history: true}

        :imported ->
          %{acc | imported: true}

        :closed ->
          %{acc | closed: true}

        invalid_flag ->
          raise ArgumentError,
                "Invalid account flag: #{inspect(invalid_flag)}. " <>
                  "Valid flags are: [:linked, :debits_must_not_exceed_credits, " <>
                  ":credits_must_not_exceed_debits, :history, :imported, :closed]"
      end
    end)
  end

  @doc """
  Builds flags for a transfer from a list of atoms.

  Valid flags include: [:linked, :pending, :post_pending_transfer, :void_pending_transfer, 
  :balancing_debit, :balancing_credit, :closing_debit, :closing_credit, :imported]

  ## Examples

      iex> build_transfer_flags([:linked, :post_pending_transfer])
      %TransferFlags{linked: true, post_pending_transfer: true}
      
      iex> build_transfer_flags([])
      %TransferFlags{}
  """
  def build_transfer_flags(flags) when is_list(flags) do
    # Start with default struct (all flags set to false)
    Enum.reduce(flags, %TransferFlags{}, fn flag, acc ->
      case flag do
        :linked ->
          %{acc | linked: true}

        :pending ->
          %{acc | pending: true}

        :post_pending_transfer ->
          %{acc | post_pending_transfer: true}

        :void_pending_transfer ->
          %{acc | void_pending_transfer: true}

        :balancing_debit ->
          %{acc | balancing_debit: true}

        :balancing_credit ->
          %{acc | balancing_credit: true}

        :closing_debit ->
          %{acc | closing_debit: true}

        :closing_credit ->
          %{acc | closing_credit: true}

        :imported ->
          %{acc | imported: true}

        invalid_flag ->
          raise ArgumentError,
                "Invalid transfer flag: #{inspect(invalid_flag)}. " <>
                  "Valid flags are: [:linked, :pending, :post_pending_transfer, :void_pending_transfer, " <>
                  ":balancing_debit, :balancing_credit, :closing_debit, :closing_credit, :imported]"
      end
    end)
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
          get_asset_scale_for_ledger(attrs.ledger, user) ||
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

  # Helper function to get the asset scale for a specific ledger
  # This would likely be a lookup in your ledger configuration
  defp get_asset_scale_for_ledger(ledger_id, user) do
    # You might have this configured per ledger in your database or TypeCache
    # For example:
    case TypeCache.get_ledger_asset_scale_by_id(ledger_id, user) do
      {:ok, scale} -> scale
      {:error, :not_found} -> nil
    end
  end

  # Converts a UUID v7 string to a 128-bit binary ID for TigerBeetle.
  defp uuidv7_to_128bit(uuidv7) do
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
  defp timestamp_now do
    System.system_time(:millisecond)
  end

  # Get locale code for user_data_32
  defp get_locale_code(locale) when is_binary(locale) do
    case TypeCache.get_user_locale() do
      {:ok, locale} ->
        Map.get(@locale_codes, locale) || 0

      {:error, _} ->
        "en"
    end
  end
end
