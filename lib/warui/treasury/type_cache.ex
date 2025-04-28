defmodule Warui.Treasury.TypeCache do
  @moduledoc """
  Handles caching operations for TigerBeetle type mappings.
  Uses the existing Warui.Cache for storage.
  """

  use Nebulex.Caching

  alias Warui.Treasury.{AccountType, TransferType, AssetType}
  alias Warui.Cache
  require Ash.Query

  @ttl :timer.hours(24)

  @doc """
  Initializes all type caches when the application starts
  """
  def init_caches do
    init_account_types()
    init_transfer_types()
    init_asset_types()
    :ok
  end

  # Account Type cache operations

  def init_account_types do
    account_types =
      AccountType
      |> Ash.Query.sort(:code)
      |> Ash.read!()

    # Cache by name
    Enum.each(account_types, fn type ->
      Cache.put({:account_type, :name, type.name}, type, ttl: @ttl)
    end)

    # Cache by code
    Enum.each(account_types, fn type ->
      Cache.put({:account_type, :code, type.code}, type, ttl: @ttl)
    end)
  end

  @decorate cacheable(cache: Cache, key: {:account_type, :name, name}, opts: [ttl: @ttl])
  def get_account_type_by_name(name) when is_binary(name) do
    account_type =
      AccountType
      |> Ash.Query.filter(name == ^name)
      |> Ash.read_one()

    case account_type do
      {:ok, type} -> {:ok, type}
      {:error, _} -> {:error, :not_found}
    end
  end

  @decorate cacheable(cache: Cache, key: {:account_type, :code, code}, opts: [ttl: @ttl])
  def get_account_type_by_code(code) when is_integer(code) do
    account_type =
      AccountType
      |> Ash.Query.filter(code == ^code)
      |> Ash.read_one()

    case account_type do
      {:ok, type} -> {:ok, type}
      {:error, _} -> {:error, :not_found}
    end
  end

  @decorate cache_put(
              cache: Cache,
              keys: [{:account_type, :name, attrs.name}, {:account_type, :code, attrs.code}],
              match: &match_update/1
            )
  def update_account_type(attrs) do
    AccountType
    |> Ash.Changeset.for_update(attrs)
    |> Ash.update!()
  end

  @decorate cache_evict(
              cache: Cache,
              keys: [{:account_type, :name, type.name}, {:account_type, :code, type.code}]
            )
  def delete_account_type(type) do
    AccountType
    |> Ash.Changeset.for_destroy(type)
    |> Ash.destroy!()
  end

  # Transfer Type cache operations

  def init_transfer_types do
    transfer_types =
      TransferType
      |> Ash.Query.sort(:code)
      |> Ash.read!()

    # Cache by name
    Enum.each(transfer_types, fn type ->
      Cache.put({:transfer_type, :name, type.name}, type, ttl: @ttl)
    end)

    # Cache by code
    Enum.each(transfer_types, fn type ->
      Cache.put({:transfer_type, :code, type.code}, type, ttl: @ttl)
    end)
  end

  @decorate cacheable(cache: Cache, key: {:transfer_type, :name, name}, opts: [ttl: @ttl])
  def get_transfer_type_by_name(name) when is_binary(name) do
    transfer_type =
      TransferType
      |> Ash.Query.filter(name == ^name)
      |> Ash.read_one()

    case transfer_type do
      {:ok, type} -> {:ok, type}
      {:error, _} -> {:error, :not_found}
    end
  end

  @decorate cacheable(cache: Cache, key: {:transfer_type, :code, code}, opts: [ttl: @ttl])
  def get_transfer_type_by_code(code) when is_integer(code) do
    transfer_type =
      TransferType
      |> Ash.Query.filter(code == ^code)
      |> Ash.read_one()

    case transfer_type do
      {:ok, type} -> {:ok, type}
      {:error, _} -> {:error, :not_found}
    end
  end

  # Asset Type (Ledger) cache operations

  def init_asset_types do
    asset_types =
      AssetType
      |> Ash.Query.sort(:code)
      |> Ash.read!()

    # Cache by name
    Enum.each(asset_types, fn type ->
      Cache.put({:asset_type, :name, type.name}, type, ttl: @ttl)
    end)

    # Cache by code
    Enum.each(asset_types, fn type ->
      Cache.put({:asset_type, :code, type.code}, type, ttl: @ttl)
    end)
  end

  @decorate cacheable(cache: Cache, key: {:asset_type, :name, name}, opts: [ttl: @ttl])
  def get_asset_type_by_name(name) when is_binary(name) do
    asset_type =
      AssetType
      |> Ash.Query.filter(name == ^name)
      |> Ash.read_one()

    case asset_type do
      {:ok, type} -> {:ok, type}
      {:error, _} -> {:error, :not_found}
    end
  end

  @decorate cacheable(cache: Cache, key: {:asset_type, :code, code}, opts: [ttl: @ttl])
  def get_asset_type_by_code(code) when is_integer(code) do
    asset_type =
      AssetType
      |> Ash.Query.filter(code == ^code)
      |> Ash.read_one()

    case asset_type do
      {:ok, type} -> {:ok, type}
      {:error, _} -> {:error, :not_found}
    end
  end

  # Helper function for cache_put match
  defp match_update({:ok, type}), do: {true, type}
  defp match_update({:error, _}), do: false
end
