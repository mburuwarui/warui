defmodule Warui.Treasury.Helpers.Seeders.CurrenciesTest do
  use Warui.DataCase, async: false
  alias Warui.Treasury.Helpers.Seeders.Currencies
  alias Warui.Cache
  alias Warui.Treasury.Currency
  require Ash.Query

  @ttl :timer.minutes(1)

  describe "Currencies seeder tests" do
    test "seed/0 caches currencies" do
      Currencies.seed()

      # Check caching
      currency =
        Currency
        |> Ash.Query.filter(name == "Kenya Shilling")
        |> Ash.Query.set_tenant("system_organization")
        |> Ash.read_one!()

      Cache.put({:currency, :name, currency.name}, currency, ttl: @ttl)

      assert Cache.has_key?({:currency, :name, currency.name})
      assert Cache.get({:currency, :name, currency.name}) == currency

      currencies =
        Currency
        |> Ash.Query.sort(:name)
        |> Ash.Query.set_tenant("system_organization")
        |> Ash.read!()

      # Cache by name
      assert Enum.each(currencies, fn currency ->
               Cache.put({:currency, :symbol, currency.symbol}, currency, ttl: @ttl)
             end)

      assert Cache.has_key?({:currency, :symbol, "UGX"})
    end
  end
end

