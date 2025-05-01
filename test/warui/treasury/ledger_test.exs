defmodule Warui.Treasury.LedgerTest do
  use WaruiWeb.ConnCase, async: false
  require Ash.Query
  alias Warui.Cache
  alias Warui.Treasury.Helpers.TypeCache
  alias Warui.Treasury.Helpers.Seeder

  describe "Ledger tests" do
    test "User personal ledger can be created" do
      # create_user/0 is automatically imported from ConnCase
      user = create_user()
      # Create a new team for the user
      organization_attrs = %{name: "Org 1", domain: "org_1", owner_user_id: user.id}
      {:ok, _organization} = Ash.create(Warui.Accounts.Organization, organization_attrs)

      Seeder.seed_treasury_types(user)
      TypeCache.init_caches(user)

      currency_id = TypeCache.get_currency_id_by_name("Kenya Shilling", user)
      asset_type_id = TypeCache.get_asset_type_id_by_name("Cash", user)

      assert Cache.has_key?({:currency, :id, currency_id})
      assert currency_id == Cache.get({:currency, :id, currency_id}).id

      # Verify the currency exists in the database
      assert Warui.Treasury.Currency
             |> Ash.Query.filter(id == ^currency_id)
             |> Ash.read_one!(actor: user)

      ledger_attrs = %{
        name: "Personal",
        currency_id: currency_id,
        asset_type_id: asset_type_id,
        ledger_owner_id: user.id
      }

      ledger = Ash.create!(Warui.Treasury.Ledger, ledger_attrs, actor: user)

      # New ledger should be stored successfully
      assert Warui.Treasury.Ledger
             |> Ash.Query.filter(currency_id == ^currency_id)
             |> Ash.Query.filter(ledger_owner_id == ^user.id)
             |> Ash.exists?(actor: user)

      # Verify the ledger was created
      assert ledger.id != nil
      assert ledger.currency_id == currency_id
    end
  end
end
