defmodule Warui.Treasury.Helpers.TypeCache do
  @moduledoc """
  Handles caching operations for TigerBeetle type mappings.
  Uses the existing Warui.Cache for storage.
  """

  use Nebulex.Caching

  alias Warui.Treasury.{Account, Ledger, AccountType, TransferType, AssetType, Currency}
  alias Warui.Accounts.User
  alias Warui.Cache
  require Ash.Query
  require Logger

  @ttl :timer.minutes(1)

  @doc """
  Initializes all type caches when the application starts
  """
  def init_caches(user) do
    init_asset_types(user)
    init_account_types(user)
    init_transfer_types(user)
    init_currencies(user)
    init_user_locale()
    :ok
  end

  # Asset Type (Ledger) cache operations
  def init_asset_types(user) do
    asset_types =
      AssetType
      |> Ash.Query.sort(:code)
      |> Ash.read!(actor: user)

    # Cache by name
    Enum.each(asset_types, fn type ->
      Cache.put({:asset_type, :name, type.name}, type, ttl: @ttl)
    end)

    # Cache by code
    Enum.each(asset_types, fn type ->
      Cache.put({:asset_type, :code, type.code}, type, ttl: @ttl)
    end)
  end

  # Account Type cache operations
  def init_account_types(user) do
    account_types =
      AccountType
      |> Ash.Query.sort(:code)
      |> Ash.read!(actor: user)

    # Cache by name
    Enum.each(account_types, fn type ->
      Cache.put({:account_type, :name, type.name}, type, ttl: @ttl)
    end)

    # Cache by code
    Enum.each(account_types, fn type ->
      Cache.put({:account_type, :code, type.code}, type, ttl: @ttl)
    end)
  end

  # Transfer Type cache operations
  def init_transfer_types(user) do
    transfer_types =
      TransferType
      |> Ash.Query.sort(:code)
      |> Ash.read!(actor: user)

    # Cache by name
    Enum.each(transfer_types, fn type ->
      Cache.put({:transfer_type, :name, type.name}, type, ttl: @ttl)
    end)

    # Cache by code
    Enum.each(transfer_types, fn type ->
      Cache.put({:transfer_type, :code, type.code}, type, ttl: @ttl)
    end)
  end

  def init_currencies(user) do
    currencies =
      Currency
      |> Ash.Query.sort(:name)
      |> Ash.read!(actor: user)

    # Cache by name
    Enum.each(currencies, fn type ->
      Cache.put({:currency, :name, type.name}, type, ttl: @ttl)
    end)

    # Cache by id 
    Enum.each(currencies, fn type ->
      Cache.put({:currency, :id, type.id}, type, ttl: @ttl)
    end)
  end

  def get_currency_id_by_name(name, user) when is_binary(name) do
    case get_currency_by_name(name, user) do
      {:ok, currency} -> currency.id
      {:error, :not_found} -> raise "Currency not found: #{name}"
    end
  end

  def get_asset_type_id_by_name(name, user) when is_binary(name) do
    case get_asset_type_by_name(name, user) do
      {:ok, asset_type} -> asset_type.id
      {:error, :not_found} -> raise "Asset type not found: #{name}"
    end
  end

  def get_asset_type_code_by_name(name, user) when is_binary(name) do
    case get_asset_type_by_name(name, user) do
      {:ok, asset_type} -> asset_type.code
      {:error, :not_found} -> raise "Asset type not found: #{name}"
    end
  end

  def get_account_type_id_by_name(name, user) when is_binary(name) do
    case get_account_type_by_name(name, user) do
      {:ok, account_type} -> account_type.id
      {:error, :not_found} -> raise "Account type not found: #{name}"
    end
  end

  def get_account_type_code_by_name(name, user) when is_binary(name) do
    case get_account_type_by_name(name, user) do
      {:ok, account_type} -> account_type.code
      {:error, :not_found} -> raise "Account type not found: #{name}"
    end
  end

  def get_transfer_type_id_by_name(name, user) when is_binary(name) do
    case get_transfer_type_by_name(name, user) do
      {:ok, transfer_type} -> transfer_type.id
      {:error, :not_found} -> raise "Tranfer type not found: #{name}"
    end
  end

  def get_transfer_type_code(transfer_type, user) when is_binary(transfer_type) do
    case get_transfer_type_by_name(transfer_type, user) do
      {:ok, type} ->
        type.code

      {:error, :not_found} ->
        # Fallback to standard transfer type
        {:ok, standard_type} = get_transfer_type_by_name("Payment", user)
        standard_type.code
    end
  end

  @decorate cacheable(cache: Cache, key: {:user, :id, id}, opts: [ttl: @ttl])
  def get_user_by_id(id) when is_integer(id) do
    User
    |> Ash.Query.filter(id == ^id)
    |> Ash.read_one!(authorize?: false)
  end

  @decorate cacheable(cache: Cache, key: {:ledger, :id, id}, opts: [ttl: @ttl])
  def get_ledger_by_id(id, user) when is_integer(id) do
    Ledger
    |> Ash.Query.filter(id == ^id)
    |> Ash.read_one!(actor: user)
  end

  @decorate cacheable(cache: Cache, key: {:ledger, :id, id}, opts: [ttl: @ttl])
  def get_ledger_asset_type_by_id(id, user) when is_integer(id) do
    Ledger
    |> Ash.Query.filter(id == ^id)
    |> Ash.read_one!(actor: user)
    |> Map.get(:asset_type_id)
    |> get_asset_type_by_id(user)
  end

  @decorate cacheable(cache: Cache, key: {:ledger, :id, id}, opts: [ttl: @ttl])
  def get_ledger_asset_scale_by_id(id, user) when is_integer(id) do
    Ledger
    |> Ash.Query.filter(id == ^id)
    |> Ash.read_one!(actor: user)
    |> Map.get(:asset_type_id)
    |> get_asset_type_by_id(user)
    |> Map.get(:scale)
  end

  @decorate cacheable(cache: Cache, key: {:account, :id, id}, opts: [ttl: @ttl])
  def get_account_by_id(id, user) when is_integer(id) do
    Account
    |> Ash.Query.filter(id == ^id)
    |> Ash.read_one!(actor: user)
  end

  @decorate cacheable(cache: Cache, key: {:account_type, :id, id}, opts: [ttl: @ttl])
  def get_account_type_by_id(id, user) when is_integer(id) do
    AccountType
    |> Ash.Query.filter(id == ^id)
    |> Ash.read_one!(actor: user)
  end

  @decorate cacheable(cache: Cache, key: {:account_type, :name, name}, opts: [ttl: @ttl])
  def get_account_type_by_name(name, user) when is_binary(name) do
    AccountType
    |> Ash.Query.filter(name == ^name)
    |> Ash.read_one!(actor: user)
  end

  @decorate cacheable(cache: Cache, key: {:account_type, :code, code}, opts: [ttl: @ttl])
  def get_account_type_by_code(code, user) when is_integer(code) do
    account_type =
      AccountType
      |> Ash.Query.filter(code == ^code)
      |> Ash.read_one(actor: user)

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
  def update_account_type(attrs, user) do
    AccountType
    |> Ash.Changeset.for_update(attrs)
    |> Ash.update!(actor: user)
  end

  @decorate cache_evict(
              cache: Cache,
              keys: [{:account_type, :name, type.name}, {:account_type, :code, type.code}]
            )
  def delete_account_type(type, user) do
    AccountType
    |> Ash.Changeset.for_destroy(type)
    |> Ash.destroy!(actor: user)
  end

  @decorate cacheable(cache: Cache, key: {:transfer_type, :id, id}, opts: [ttl: @ttl])
  def get_transfer_type_by_id(id, user) when is_integer(id) do
    TransferType
    |> Ash.Query.filter(id == ^id)
    |> Ash.read_one!(actor: user)
  end

  @decorate cacheable(cache: Cache, key: {:transfer_type, :name, name}, opts: [ttl: @ttl])
  def get_transfer_type_by_name(name, user) when is_binary(name) do
    TransferType
    |> Ash.Query.filter(name == ^name)
    |> Ash.read_one!(actor: user)
  end

  @decorate cacheable(cache: Cache, key: {:transfer_type, :code, code}, opts: [ttl: @ttl])
  def get_transfer_type_by_code(code, user) when is_integer(code) do
    transfer_type =
      TransferType
      |> Ash.Query.filter(code == ^code)
      |> Ash.read_one(actor: user)

    case transfer_type do
      {:ok, type} -> {:ok, type}
      {:error, _} -> {:error, :not_found}
    end
  end

  @decorate cacheable(cache: Cache, key: {:asset_type, :id, id}, opts: [ttl: @ttl])
  def get_asset_type_by_id(id, user) when is_integer(id) do
    AssetType
    |> Ash.Query.filter(id == ^id)
    |> Ash.read_one!(actor: user)
  end

  @decorate cacheable(cache: Cache, key: {:asset_type, :name, name}, opts: [ttl: @ttl])
  def get_asset_type_by_name(name, user) when is_binary(name) do
    AssetType
    |> Ash.Query.filter(name == ^name)
    |> Ash.read_one!(actor: user)
  end

  @decorate cacheable(cache: Cache, key: {:asset_type, :code, code}, opts: [ttl: @ttl])
  def get_asset_type_by_code(code, user) when is_integer(code) do
    AssetType
    |> Ash.Query.filter(code == ^code)
    |> Ash.read_one!(actor: user)
  end

  @decorate cacheable(cache: Cache, key: {:currency, :name, name}, opts: [ttl: @ttl])
  def get_currency_by_name(name, user) when is_binary(name) do
    Currency
    |> Ash.Query.filter(name == ^name)
    |> Ash.read_one!(actor: user)
  end

  @doc """
  Gets the cached locale for a specific user.
  Falls back to Gettext's current locale if not found.
  """
  def init_user_locale do
    user_locale = Gettext.get_locale()

    Cache.put({:user_locale, user_locale}, user_locale, ttl: @ttl)
  end

  @decorate cacheable(cache: Cache, key: {:user_locale}, opts: [ttl: @ttl])
  def get_user_locale do
    user_locale = Gettext.get_locale()

    {:ok, user_locale}
  end

  def system_user do
    case get_first_user() do
      {:ok, nil} ->
        # No user found, create one
        user =
          Ash.Seed.seed!(Warui.Accounts.User, %{
            email: "system@example.com",
            current_organization: "system_organization"
          })

        Logger.info("Created new system user with ID: #{inspect(user)}")

        # Create the organization
        organization =
          Ash.Seed.seed!(Warui.Accounts.Organization, %{
            name: "System Organization",
            domain: "system_organization",
            owner_user_id: user.id
          })

        Logger.info("Created system organization with ID: #{inspect(organization)}")

        user

      {:ok, user} ->
        Logger.debug("Found existing user: #{inspect(user)}")
        user

      {:error, error} ->
        Logger.error("Error finding or creating system user: #{inspect(error)}")
        nil
    end
  end

  defp get_first_user do
    Warui.Accounts.User
    |> Ash.Query.limit(1)
    |> Ash.read_one(authorize?: false)
  end

  # Helper function for cache_put match
  defp match_update({:ok, type}), do: {true, type}
  defp match_update({:error, _}), do: false
end
