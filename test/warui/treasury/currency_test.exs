defmodule Warui.Treasury.Helpers.Seeders.CurrenciesTest do
  use WaruiWeb.ConnCase, async: false
  alias Warui.Treasury.Helpers.Seeder
  alias Warui.Cache
  alias Warui.Treasury.Currency
  require Ash.Query

  @ttl :timer.minutes(1)

  describe "Currencies seeder tests" do
    test "seed/0 caches currencies" do
      user = create_user()

      # Create a new team for the user
      organization_attrs = %{name: "Org 1", domain: "org_1", owner_user_id: user.id}
      {:ok, organization} = Ash.create(Warui.Accounts.Organization, organization_attrs)

      Seeder.seed_treasury_types(organization.domain)

      # Check caching
      currency =
        Currency
        |> Ash.Query.filter(name == "Kenya Shilling")
        |> Ash.Query.set_tenant(organization.domain)
        |> Ash.read_one!()

      Cache.put({:currency, :name, currency.name}, currency, ttl: @ttl)

      assert Cache.has_key?({:currency, :name, currency.name})
      assert currency == Cache.get({:currency, :name, currency.name})

      currencies =
        Currency
        |> Ash.Query.sort(:name)
        |> Ash.Query.set_tenant(organization.domain)
        |> Ash.read!()

      # Cache by name
      assert Enum.each(currencies, fn currency ->
               Cache.put({:currency, :symbol, currency.symbol}, currency, ttl: @ttl)
             end)

      assert Cache.has_key?({:currency, :symbol, "UGX"})
    end
  end
end
