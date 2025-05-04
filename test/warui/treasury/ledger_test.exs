defmodule Warui.Treasury.LedgerTest do
  use WaruiWeb.ConnCase, async: false
  require Ash.Query
  alias Warui.Cache
  alias Warui.Treasury.Helpers.TypeCache
  alias Warui.Treasury.Helpers.Seeder
  alias Warui.Treasury.Ledger
  alias Warui.Treasury.Currency

  describe "Ledger tests" do
    test "User personal ledger can be created" do
      # create_user/0 is automatically imported from ConnCase
      user = create_user("John")

      Seeder.seed_treasury_types(user)
      TypeCache.init_caches(user)

      currency_id = TypeCache.currency_id("Kenya Shilling", user)
      asset_type_id = TypeCache.asset_type_id("Cash", user)

      assert Cache.has_key?({:currency, :id, currency_id})
      assert currency_id == Cache.get({:currency, :id, currency_id}).id

      # Verify the currency exists in the database
      assert Currency
             |> Ash.Query.filter(id == ^currency_id)
             |> Ash.read_one!(actor: user)

      ledger_attrs = %{
        name: "Personal",
        currency_id: currency_id,
        asset_type_id: asset_type_id,
        ledger_owner_id: user.id
      }

      ledger = Ash.create!(Ledger, ledger_attrs, actor: user)

      # New ledger should be stored successfully
      assert Ledger
             |> Ash.Query.filter(currency_id == ^currency_id)
             |> Ash.Query.filter(ledger_owner_id == ^user.id)
             |> Ash.exists?(actor: user)

      # Verify the ledger was created
      assert ledger.id != nil
      assert ledger.currency_id == currency_id
    end
  end
end
