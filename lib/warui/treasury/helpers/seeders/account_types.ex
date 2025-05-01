defmodule Warui.Treasury.Helpers.Seeders.AccountTypes do
  alias Warui.Treasury.AccountType
  require Ash.Query

  def seed(user) do
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
        exists? =
          AccountType
          |> Ash.Query.filter(name == ^account_type.name)
          |> Ash.exists?(actor: user)

        if !exists? do
          AccountType
          |> Ash.Changeset.for_create(:create, account_type, actor: user)
          |> Ash.create!()
        end
      end
    )
  end
end
