defmodule Warui.Treasury.AccountTest do
  use WaruiWeb.ConnCase, async: false
  require Ash.Query
  alias Warui.Cache
  alias Warui.Treasury.Helpers.TypeCache
  alias Warui.Treasury.Account

  describe "Account tests" do
    test "User default account can be created" do
      # create_user/1 is automatically imported from ConnCase
      user = create_user("John")

      ledger = create_ledger("Personal", user.id)
      account_type_id = TypeCache.account_type_id("Checking", user)

      assert Cache.has_key?({:account_type, :id, account_type_id})
      assert account_type_id == Cache.get({:account_type, :id, account_type_id}).id

      account_attrs = %{
        name: "Default Account",
        account_owner_id: user.id,
        account_ledger_id: ledger.id,
        account_type_id: account_type_id,
        flags: %{
          history: true
        }
      }

      account = Ash.create!(Account, account_attrs, actor: user)

      # New account should be stored successfully
      assert Account
             |> Ash.Query.filter(name == ^account.name)
             |> Ash.Query.filter(account_owner_id == ^ledger.ledger_owner_id)
             |> Ash.exists?(actor: user)

      # # New account should be set as the default user account
      # assert Warui.Accounts.User
      #        |> Ash.Query.filter(id == ^user.id)
      #        |> Ash.Query.filter(current_account == ^user_account.id)
      #        # authorize?: false disables policy checks
      #        |> Ash.exists?(authorize?: false)

      # New account should be added to the accounts list of the owner
      # assert Warui.Accounts.User
      #        |> Ash.Query.filter(id == ^user.id)
      #        |> Ash.Query.filter(accounts.id == ^account.id)
      #        |> Ash.exists?(authorize?: false)
    end
  end
end
