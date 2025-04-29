defmodule Warui.Treasury.Helpers.Seeders.AssetTypes do
  alias Warui.Treasury.AssetType
  use Nebulex.Caching
  alias Warui.Cache
  require Ash.Query

  @ttl :timer.hours(24)

  def seed do
    currency_id = default_currency_id()

    default_asset_types = [
      %{
        name: "Cash",
        code: 1,
        currency_id: currency_id
      },
      %{
        name: "Bond",
        code: 2,
        currency_id: currency_id
      },
      %{
        name: "Stock",
        code: 3,
        currency_id: currency_id
      },
      %{
        name: "Real Estate",
        code: 4,
        currency_id: currency_id
      },
      %{
        name: "Commodity",
        code: 5,
        currency_id: currency_id
      },
      %{
        name: "Fund",
        code: 6,
        currency_id: currency_id
      },
      %{
        name: "Derivative",
        code: 7,
        currency_id: currency_id
      }
    ]

    Enum.each(
      default_asset_types,
      fn asset_type ->
        if !Ash.exists?(
             AssetType
             |> Ash.Query.filter(name == ^asset_type.name)
             |> Ash.Query.set_tenant("system_organization")
           ) do
          AssetType
          |> Ash.Changeset.for_create(:create, asset_type, tenant: "system_organization")
          |> Ash.create!()

          Cache.put({:asset_type, :name, asset_type.name}, asset_type, ttl: @ttl)
          Cache.put({:asset_type, :code, asset_type.code}, asset_type, ttl: @ttl)
        end
      end
    )
  end

  defp default_currency_id do
    currency =
      Warui.Treasury.Currency
      |> Ash.Query.filter(name == "Kenya Shilling")
      |> Ash.Query.set_tenant("system_organization")
      |> Ash.read_one!()

    currency.id
  end
end
