defmodule Warui.Treasury.Helpers.TigerbeetleService do
  @moduledoc """
  Service module for interacting with TigerBeetle with cached types
  """
  alias Warui.Treasury.Helpers.TypeCache

  @locale_codes %{
    "en" => 1,
    "en_GB" => 2,
    "en_KE" => 3,
    "fr_FR" => 4,
    "de_DE" => 5
  }

  @doc """
  Convert a UUID to a 128-bit binary for TigerBeetle
  """
  def uuidv7_to_128bit(uuidv7) do
    Ash.UUIDv7.decode(uuidv7)
  end

  @doc """
  Get the ledger code for a currency
  """
  def get_asset_type_code(currency, user) when is_binary(currency) do
    case TypeCache.get_asset_type_by_name(currency, user) do
      {:ok, asset_type} -> asset_type.code
      {:error, :not_found} -> raise "Unsupported currency: #{currency}"
    end
  end

  @doc """
  Get the account type code
  """
  def get_account_type_code(account_type, user) when is_binary(account_type) do
    case TypeCache.get_account_type_by_name(account_type, user) do
      {:ok, type} ->
        type.code

      {:error, :not_found} ->
        # Fallback to customer account type
        {:ok, customer_type} = TypeCache.get_account_type_by_name("Checking", user)
        customer_type.code
    end
  end

  @doc """
  Get the transfer type code
  """
  def get_transfer_type_code(transfer_type, user) when is_binary(transfer_type) do
    case TypeCache.get_transfer_type_by_name(transfer_type, user) do
      {:ok, type} ->
        type.code

      {:error, :not_found} ->
        # Fallback to standard transfer type
        {:ok, standard_type} = TypeCache.get_transfer_type_by_name("Payment", user)
        standard_type.code
    end
  end

  @doc """
  Extract timestamp for user_data_64
  """
  def timestamp_to_user_data_64 do
    System.system_time(:millisecond)
  end

  @doc """
  Encode metadata to binary for user_data_128
  """
  def encode_metadata_to_user_data_128(metadata) when is_map(metadata) do
    metadata
    |> :erlang.term_to_binary()
    |> :crypto.hash(:md5)
  end

  def encode_metadata_to_user_data_128(id) when is_binary(id) do
    if String.length(id) == 36 do
      # Handle UUID
      uuidv7_to_128bit(id)
    else
      # Handle any other binary
      :crypto.hash(:md5, id)
    end
  end

  @doc """
  Get locale code for user_data_32
  """
  def get_locale_code(locale) when is_binary(locale) do
    case TypeCache.get_user_locale() do
      {:ok, locale} ->
        Map.get(@locale_codes, locale) || 0

      {:error, _} ->
        "en"
    end
  end

  @doc """
  Get current balance for an account from TigerBeetle
  """
  def get_account_balance(tb_account_id) do
    case TigerBeetlex.Connection.lookup_accounts(:tb, [tb_account_id]) do
      {:ok, [account]} ->
        # TigerBeetle account has debits_posted and credits_posted
        # Balance is credits - debits (accounting convention)
        balance = account.credits_posted - account.debits_posted
        {:ok, balance}

      {:ok, []} ->
        {:error, :account_not_found}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
