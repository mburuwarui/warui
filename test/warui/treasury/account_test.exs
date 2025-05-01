defmodule Warui.Treasury.AccountTest do
  use WaruiWeb.ConnCase, async: false
  require Ash.Query
  alias Warui.Cache
  alias Warui.Treasury.Helpers.TypeCache
  alias Warui.Treasury.Helpers.Seeder

  describe "Account tests" do
    test "User default account can be created" do
      # create_user/0 is automatically imported from ConnCase
      user = create_user()

      # Create a new team for the user
      organization_attrs = %{name: "Org 1", domain: "org_1", owner_user_id: user.id}
      {:ok, organization} = Ash.create(Warui.Accounts.Organization, organization_attrs)

      Seeder.seed_treasury_types(user)
      currency = TypeCache.get_currency_by_name("Kenya Shilling", user)
      asset_type = TypeCache.get_asset_type_by_name("Cash", user)
      account_type = TypeCache.get_account_type_by_name("Checking", user)

      assert Cache.has_key?({:currency, :name, currency.name})
      assert currency == Cache.get({:currency, :name, currency.name})

      ledger_attrs = %{
        name: "Personal",
        currency_id: currency.id,
        asset_type_id: asset_type.id,
        ledger_owner_id: user.id
      }

      ledger = Ash.create!(Warui.Treasury.Ledger, ledger_attrs, actor: user)

      account_attrs = %{
        name: "Default Account",
        user_id: user.id,
        account_ledger_id: ledger.id,
        account_type_id: account_type.id
      }

      account = Ash.create!(Warui.Treasury.Account, account_attrs, actor: user)

      # New account should be stored successfully
      assert Warui.Treasury.Account
             |> Ash.Query.filter(name == ^account.name)
             |> Ash.Query.filter(owner_id == ^organization.owner_user_id)
             |> Ash.exists?(actor: user)

      # # New account should be set as the default user account
      # assert Warui.Accounts.User
      #        |> Ash.Query.filter(id == ^user.id)
      #        |> Ash.Query.filter(current_account == ^user_account.id)
      #        # authorize?: false disables policy checks
      #        |> Ash.exists?(authorize?: false)
      #
      # # New account should be added to the accounts list of the owner
      # assert Warui.Accounts.User
      #        |> Ash.Query.filter(id == ^user.id)
      #        |> Ash.Query.filter(accounts.id == ^account.id)
      #        |> Ash.exists?(authorize?: false)
    end
  end
end
