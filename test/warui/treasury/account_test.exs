defmodule Warui.Treasury.AccountTest do
  use WaruiWeb.ConnCase, async: false
  require Ash.Query
  alias Warui.Cache
  alias Warui.Treasury.Helpers.TypeCache
  alias Warui.Treasury.Helpers.Seeder

  describe "Ledger tests" do
    test "User ledger can be created" do
      # create_user/0 is automatically imported from ConnCase
      user = create_user()

      # Create a new team for the user
      organization_attrs = %{name: "Org 1", domain: "org_1", owner_user_id: user.id}
      {:ok, organization} = Ash.create(Warui.Accounts.Organization, organization_attrs)

      Seeder.seed_treasury_types(organization.domain)
      currency = TypeCache.get_currency_by_name("Kenya Shilling", organization.domain)
      asset_type = TypeCache.get_asset_type_by_name("Cash", organization.domain)
      account_type = TypeCache.get_account_type_by_name("Checking", organization.domain)

      assert Cache.has_key?({:currency, :name, currency.name})
      assert currency == Cache.get({:currency, :name, currency.name})

      ledger_attrs = %{
        name: "Personal",
        owner_id: organization.owner_user_id,
        currency_id: currency.id,
        asset_type_id: asset_type.id,
        tenant: organization.domain
      }

      ledger = Ash.create!(Warui.Treasury.Ledger, ledger_attrs, tenant: organization.domain)

      account_attrs = %{
        name: "Default Account",
        owner_id: ledger.owner_id,
        ledger_id: ledger.id,
        account_type_id: account_type.id
      }

      account = Ash.create!(Warui.Treasury.Account, account_attrs, tenant: organization.domain)

      # New account should be stored successfully
      assert Warui.Treasury.Account
             |> Ash.Query.filter(name == ^account.name)
             |> Ash.Query.filter(owner_id == ^organization.owner_user_id)
             |> Ash.Query.set_tenant(organization.domain)
             |> Ash.exists?()

      # # New ledger should be set as the default user ledger
      # assert Warui.Accounts.User
      #        |> Ash.Query.filter(id == ^user.id)
      #        |> Ash.Query.filter(current_organization == ^organization.domain)
      #        # authorize?: false disables policy checks
      #        |> Ash.exists?(authorize?: false)
      #
      # # New ledger should be added to the ledgers list of the owner
      # assert Warui.Accounts.User
      #        |> Ash.Query.filter(id == ^user.id)
      #        |> Ash.Query.filter(organizations.id == ^organization.id)
      #        |> Ash.exists?(authorize?: false)
    end
  end
end
