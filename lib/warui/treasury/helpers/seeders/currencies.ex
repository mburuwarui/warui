defmodule Warui.Treasury.Helpers.Seeders.Currencies do
  alias Warui.Treasury.Currency
  require Ash.Query

  def seed(tenant) do
    default_currencies = [
      %{
        name: "Kenya Shilling",
        symbol: "KES",
        scale: 2
      },
      %{
        name: "US Dollar",
        symbol: "USD",
        scale: 2
      },
      %{
        name: "Euro",
        symbol: "EUR",
        scale: 2
      },
      %{
        name: "Pound Sterling",
        symbol: "GBP",
        scale: 2
      },
      %{
        name: "Bitcoin",
        symbol: "BTC",
        scale: 8
      },
      %{
        name: "Tanzania Shilling",
        symbol: "TZS",
        scale: 2
      },
      %{
        name: "Uganda Shilling",
        symbol: "UGX",
        scale: 2
      }
    ]

    Enum.each(
      default_currencies,
      fn currency ->
        if !Ash.exists?(
             Currency
             |> Ash.Query.filter(name == ^currency.name)
             |> Ash.Query.set_tenant(tenant)
           ) do
          Currency
          |> Ash.Changeset.for_create(:create, currency, tenant: tenant)
          |> Ash.create!()
        end
      end
    )
  end
end
