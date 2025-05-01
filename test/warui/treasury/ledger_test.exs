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
      {:ok, organization} = Ash.create(Warui.Accounts.Organization, organization_attrs)

      Seeder.seed_treasury_types(user)
      currency = TypeCache.get_currency_by_name("Kenya Shilling", user)
      asset_type = TypeCache.get_asset_type_by_name("Cash", user)

      assert Cache.has_key?({:currency, :name, currency.name})
      assert currency == Cache.get({:currency, :name, currency.name})

      ledger_attrs = %{
        name: "Personal",
        currency_id: currency.id,
        asset_type_id: asset_type.id,
        ledger_owner_id: user.id
      }

      Ash.create!(Warui.Treasury.Ledger, ledger_attrs, actor: user)

      # New ledger should be stored successfully
      assert Warui.Treasury.Ledger
             |> Ash.Query.filter(currency == ^currency.id)
             |> Ash.Query.filter(owner_id == ^organization.owner_user_id)
             |> Ash.exists?(actor: user)

      # # New ledger should be set as the default user ledger
      # assert Warui.Accounts.User
      #        |> Ash.Query.filter(id == ^user.id)
      #        |> Ash.Query.filter(current_ledger == ^user_ledger.id)
      #        # authorize?: false disables policy checks
      #        |> Ash.exists?(authorize?: false)
      #
      # # New ledger should be added to the ledgers list of the owner
      # assert Warui.Accounts.User
      #        |> Ash.Query.filter(id == ^user.id)
      #        |> Ash.Query.filter(ledgers.id == ^ledger.id)
      #        |> Ash.exists?(authorize?: false)
    end
  end
end
