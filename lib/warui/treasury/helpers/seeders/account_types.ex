defmodule Warui.Treasury.Helpers.Seeders.AccountTypes do
  alias Warui.Treasury.AccountType
  require Ash.Query

  def seed(user) do
    default_account_types = [
      %{
        name: "Checking",
        code: 11
      },
      %{
        name: "Business",
        code: 12
      },
      %{
        name: "Merchant",
        code: 13
      },
      %{
        name: "Savings",
        code: 14
      },
      %{
        name: "Reimbursement",
        code: 15
      },
      %{
        name: "Tax",
        code: 16
      },
      %{
        name: "Fees",
        code: 17
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
