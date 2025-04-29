defmodule Warui.Treasury.Helpers.Seeders.Currencies do
  alias Warui.Treasury.Currency
  use Nebulex.Caching
  alias Warui.Cache
  require Ash.Query

  @ttl :timer.hours(24)

  def seed do
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
             |> Ash.Query.set_tenant("system_organization")
           ) do
          Currency
          |> Ash.Changeset.for_create(:create, currency, tenant: "system_organization")
          |> Ash.create!()

          Cache.put({:currency, :name, currency.name}, currency, ttl: @ttl)
          Cache.put({:currency, :symbol, currency.symbol}, currency, ttl: @ttl)
          Cache.put({:currency, :scale, currency.scale}, currency, ttl: @ttl)
        end
      end
    )
  end
end
