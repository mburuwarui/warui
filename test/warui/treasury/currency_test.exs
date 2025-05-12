defmodule Warui.Treasury.Helpers.Seeders.CurrencyTest do
  use WaruiWeb.ConnCase, async: false
  alias Warui.Cache
  alias Warui.Treasury.Currency
  require Ash.Query

  @ttl :timer.minutes(1)

  describe "Currencies seeder tests" do
    test "seed/0 caches currencies" do
      user = create_user()

      # Check caching
      currency =
        Currency
        |> Ash.Query.filter(name == "Kenya Shilling")
        |> Ash.read_one!(actor: user)

      Cache.put({:currency, :name, {user.current_organization, currency.name}}, currency,
        ttl: @ttl
      )

      assert Cache.has_key?({:currency, :name, {user.current_organization, currency.name}})
      assert currency == Cache.get({:currency, :name, {user.current_organization, currency.name}})

      currencies =
        Currency
        |> Ash.Query.sort(:name)
        |> Ash.read!(actor: user)

      # Cache by name
      assert Enum.each(currencies, fn currency ->
               Cache.put(
                 {:currency, :symbol, {user.current_organization, currency.symbol}},
                 currency,
                 ttl: @ttl
               )
             end)

      assert Cache.has_key?({:currency, :symbol, {user.current_organization, "UGX"}})
    end
  end
end
