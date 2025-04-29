defmodule Warui.Treasury.Helpers.Seeders.AccountTypes do
  alias Warui.Treasury.AccountType
  use Nebulex.Caching
  alias Warui.Cache
  require Ash.Query

  @ttl :timer.hours(24)

  def seed do
    default_account_types = [
      %{
        name: "Checking",
        code: 1
      },
      %{
        name: "Business",
        code: 2
      },
      %{
        name: "Merchant",
        code: 3
      },
      %{
        name: "Savings",
        code: 4
      },
      %{
        name: "Reimbursement",
        code: 5
      },
      %{
        name: "Tax",
        code: 6
      },
      %{
        name: "Fees",
        code: 7
      }
    ]

    Enum.each(
      default_account_types,
      fn account_type ->
        if !Ash.exists?(
             AccountType
             |> Ash.Query.filter(name == ^account_type.name)
             |> Ash.Query.set_tenant("system_organization")
           ) do
          AccountType
          |> Ash.Changeset.for_create(:create, account_type, tenant: "system_organization")
          |> Ash.create!()

          Cache.put({:account_type, :name, account_type.name}, account_type, ttl: @ttl)
          Cache.put({:account_type, :code, account_type.code}, account_type, ttl: @ttl)
        end
      end
    )
  end
end
