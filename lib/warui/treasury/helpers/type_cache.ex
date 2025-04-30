defmodule Warui.Treasury.Helpers.TypeCache do
  @moduledoc """
  Handles caching operations for TigerBeetle type mappings.
  Uses the existing Warui.Cache for storage.
  """

  use Nebulex.Caching

  alias Warui.Treasury.{AccountType, TransferType, AssetType, Currency}
  alias Warui.Cache
  require Ash.Query

  @ttl :timer.minutes(1)

  @doc """
  Find an existing organization or create system organization for tenant
  """
  def find_or_create_system_organization do
    case get_first_organization() do
      {:ok, org} ->
        org.domain

      {:error, _} ->
        system_user = seed_system_user()

        system_org = seed_system_organization(system_user.id)

        system_org.domain
    end
  end

  @doc """
  Initializes all type caches when the application starts
  """
  def init_caches(tenant) do
    init_account_types(tenant)
    init_transfer_types(tenant)
    init_asset_types(tenant)
    init_user_locale()
    :ok
  end

  # Account Type cache operations
  def init_account_types(tenant) do
    account_types =
      AccountType
      |> Ash.Query.sort(:code)
      |> Ash.Query.set_tenant(tenant)
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
  def get_account_type_by_name(name, tenant \\ nil) when is_binary(name) do
    active_tenant = tenant || get_current_tenant()

    AccountType
    |> Ash.Query.filter(name == ^name)
    |> Ash.Query.set_tenant(active_tenant)
    |> Ash.read_one!()
  end

  @decorate cacheable(cache: Cache, key: {:account_type, :code, code}, opts: [ttl: @ttl])
  def get_account_type_by_code(code, tenant \\ nil) when is_integer(code) do
    active_tenant = tenant || get_current_tenant()

    account_type =
      AccountType
      |> Ash.Query.filter(code == ^code)
      |> Ash.Query.set_tenant(active_tenant)
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
  def update_account_type(attrs, tenant \\ nil) do
    active_tenant = tenant || get_current_tenant()

    AccountType
    |> Ash.Changeset.for_update(attrs)
    |> Ash.Changeset.set_tenant(active_tenant)
    |> Ash.update!()
  end

  @decorate cache_evict(
              cache: Cache,
              keys: [{:account_type, :name, type.name}, {:account_type, :code, type.code}]
            )
  def delete_account_type(type, tenant \\ nil) do
    active_tenant = tenant || get_current_tenant()

    AccountType
    |> Ash.Changeset.for_destroy(type)
    |> Ash.Changeset.set_tenant(active_tenant)
    |> Ash.destroy!()
  end

  # Transfer Type cache operations
  def init_transfer_types(tenant) do
    transfer_types =
      TransferType
      |> Ash.Query.sort(:code)
      |> Ash.Query.set_tenant(tenant)
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
  def get_transfer_type_by_name(name, tenant \\ nil) when is_binary(name) do
    active_tenant = tenant || get_current_tenant()

    TransferType
    |> Ash.Query.filter(name == ^name)
    |> Ash.Query.set_tenant(active_tenant)
    |> Ash.read_one!()
  end

  @decorate cacheable(cache: Cache, key: {:transfer_type, :code, code}, opts: [ttl: @ttl])
  def get_transfer_type_by_code(code, tenant \\ nil) when is_integer(code) do
    active_tenant = tenant || get_current_tenant()

    transfer_type =
      TransferType
      |> Ash.Query.filter(code == ^code)
      |> Ash.Query.set_tenant(active_tenant)
      |> Ash.read_one()

    case transfer_type do
      {:ok, type} -> {:ok, type}
      {:error, _} -> {:error, :not_found}
    end
  end

  # Asset Type (Ledger) cache operations
  def init_asset_types(tenant) do
    asset_types =
      AssetType
      |> Ash.Query.sort(:code)
      |> Ash.Query.set_tenant(tenant)
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
  def get_asset_type_by_name(name, tenant \\ nil) when is_binary(name) do
    active_tenant = tenant || get_current_tenant()

    AssetType
    |> Ash.Query.filter(name == ^name)
    |> Ash.Query.set_tenant(active_tenant)
    |> Ash.read_one!()
  end

  @decorate cacheable(cache: Cache, key: {:asset_type, :code, code}, opts: [ttl: @ttl])
  def get_asset_type_by_code(code, tenant \\ nil) when is_integer(code) do
    active_tenant = tenant || get_current_tenant()

    AssetType
    |> Ash.Query.filter(code == ^code)
    |> Ash.Query.set_tenant(active_tenant)
    |> Ash.read_one!()
  end

  @decorate cacheable(cache: Cache, key: {:currency, :name, name}, opts: [ttl: @ttl])
  def get_currency_by_name(name, tenant \\ nil) when is_binary(name) do
    active_tenant = tenant || get_current_tenant()

    Currency
    |> Ash.Query.filter(name == ^name)
    |> Ash.Query.set_tenant(active_tenant)
    |> Ash.read_one!()
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

    user_locale
  end

  # Helper function to get the current tenant
  defp get_current_tenant do
    case Process.get(:tenant) do
      nil ->
        case get_first_organization() do
          {:ok, org} -> org.domain
          # Fallback if no orgs exist
          {:error, _} -> "system_organization"
        end

      tenant ->
        tenant
    end
  end

  # Helper to get the first organization
  defp get_first_organization do
    result =
      Warui.Accounts.Organization
      |> Ash.Query.limit(1)
      |> Ash.read()

    case result do
      {:ok, [org | _]} -> {:ok, org}
      {:ok, []} -> {:error, :not_found}
      error -> error
    end
  end

  # Create system user
  defp seed_system_user do
    Ash.Seed.seed!(Warui.Accounts.User, %{
      email: "system@example.com",
      current_organization: "system_organization"
    })
  end

  # Seed system organization using the provided user ID
  defp seed_system_organization(user_id) do
    Ash.Seed.seed!(Warui.Accounts.Organization, %{
      name: "System Organization",
      domain: "system_organization",
      owner_user_id: user_id
    })
  end

  # Helper function for cache_put match
  defp match_update({:ok, type}), do: {true, type}
  defp match_update({:error, _}), do: false
end
