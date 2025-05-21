defmodule Warui.Treasury.Helpers.Seeders.AssetTypes do
  alias Warui.Treasury.AssetType
  require Ash.Query

  def seed(user) do
    currency = default_currency(user)

    default_asset_types = [
      %{
        name: "Cash",
        code: 1,
        currency_id: currency.id
      },
      %{
        name: "Bond",
        code: 2,
        currency_id: currency.id
      },
      %{
        name: "Stock",
        code: 3,
        currency_id: currency.id
      },
      %{
        name: "Estate",
        code: 4,
        currency_id: currency.id
      },
      %{
        name: "Commodity",
        code: 5,
        currency_id: currency.id
      },
      %{
        name: "Fund",
        code: 6,
        currency_id: currency.id
      },
      %{
        name: "Derivative",
        code: 7,
        currency_id: currency.id
      }
    ]

    Enum.each(
      default_asset_types,
      fn asset_type ->
        exists? =
          AssetType
          |> Ash.Query.filter(name == ^asset_type.name)
          |> Ash.exists?(actor: user)

        if !exists? do
          AssetType
          |> Ash.Changeset.for_create(:create, asset_type, actor: user)
          |> Ash.create!()
        end
      end
    )
  end

  defp default_currency(user) do
    Warui.Treasury.Currency
    |> Ash.Query.filter(name == "Kenya Shilling")
    |> Ash.read_one!(actor: user)
  end
end
