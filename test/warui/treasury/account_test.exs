defmodule Warui.Treasury.AccountTest do
  use WaruiWeb.ConnCase, async: false
  require Ash.Query
  alias Warui.Treasury.Helpers.TigerbeetleService
  alias Warui.Cache
  alias Warui.Treasury.Helpers.TypeCache
  alias Warui.Treasury.Account

  describe "Account tests" do
    test "User default account can be created" do
      # create_user/1 is automatically imported from ConnCase
      user = create_user()

      ledger = create_ledger("Personal", user.id)
      account_type_id = TypeCache.account_type_id("Checking", user)

      assert Cache.has_key?({:account_type, :id, {user.current_organization, account_type_id}})

      assert account_type_id ==
               Cache.get({:account_type, :id, {user.current_organization, account_type_id}}).id

      account_attrs = %{
        name: "Default Account",
        account_owner_id: user.id,
        account_ledger_id: ledger.id,
        account_type_id: account_type_id
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

    test "Create account with Tigerbeetle account" do
      user = create_user()
      organization_owner = user
      ledger = create_ledger("Personal", user.id)
      account_type_id = TypeCache.account_type_id("Checking", user)

      account_attrs = %{
        name: "Default Account",
        account_owner_id: user.id,
        account_ledger_id: ledger.id,
        account_type_id: account_type_id,
        organization_owner: organization_owner,
        flags: %{
          history: true
        }
      }

      account =
        Account
        |> Ash.Changeset.for_create(:create_with_tigerbeetle_account, account_attrs, actor: user)
        |> Ash.create!()

      # Build filter query
      filter = %{
        user_data_128: user.id,
        limit: 10
      }

      # retrieve query by user filter

      assert {:ok, [tb_account]} =
               TigerbeetleService.query_accounts(filter, user, organization_owner)

      assert tb_account.id == TigerbeetleService.uuidv7_to_128bit(account.id)
      assert account.account_ledger_id == ledger.id
      assert account.account_type_id == TypeCache.account_type_id("Checking", user)
    end

    test "Bulk create accounts with Tigerbeetle accounts" do
      user = create_user()
      organization_owner = user
      ledger = create_ledger("Personal", user.id)
      account_type_id = TypeCache.account_type_id("Checking", user)

      accounts =
        [
          %{
            name: "Default Account",
            account_owner_id: user.id,
            account_ledger_id: ledger.id,
            account_type_id: account_type_id,
            organization_owner: organization_owner,
            flags: %{
              history: true
            }
          },
          %{
            name: "Savings Account",
            account_owner_id: user.id,
            account_ledger_id: ledger.id,
            account_type_id: account_type_id,
            organization_owner: organization_owner,
            flags: %{
              history: true
            }
          }
        ]
        |> Ash.bulk_create!(
          Account,
          :bulk_create_with_tigerbeetle_account,
          batch_size: 100,
          return_records?: true,
          return_errors?: true,
          actor: user,
          tenant: organization_owner.current_organization
        )

      Enum.each(accounts.records, fn record ->
        assert Account
               |> Ash.Query.filter(name == ^record.name)
               |> Ash.Query.filter(account_owner_id == ^ledger.ledger_owner_id)
               |> Ash.exists?(actor: user)
      end)
    end
  end
end
