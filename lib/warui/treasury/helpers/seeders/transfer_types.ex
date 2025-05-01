defmodule Warui.Treasury.Helpers.Seeders.TransferTypes do
  alias Warui.Treasury.TransferType
  require Ash.Query

  def seed(user) do
    default_transfer_types = [
      %{
        name: "Payment",
        code: 1
      },
      %{
        name: "Subscription",
        code: 2
      },
      %{
        name: "Invoice",
        code: 3
      },
      %{
        name: "Fees",
        code: 4
      },
      %{
        name: "Settlement",
        code: 5
      },
      %{
        name: "Gift",
        code: 6
      },
      %{
        name: "Donation",
        code: 7
      }
    ]

    Enum.each(
      default_transfer_types,
      fn transfer_type ->
        exists? =
          TransferType
          |> Ash.Query.filter(name == ^transfer_type.name)
          |> Ash.exists?(actor: user)

        if !exists? do
          TransferType
          |> Ash.Changeset.for_create(:create, transfer_type, actor: user)
          |> Ash.create!()
        end
      end
    )
  end
end
