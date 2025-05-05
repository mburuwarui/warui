defmodule Warui.Treasury.Helpers.Seeders.TransferTypes do
  alias Warui.Treasury.TransferType
  require Ash.Query

  def seed(user) do
    default_transfer_types = [
      %{
        name: "Payment",
        code: 21
      },
      %{
        name: "Subscription",
        code: 22
      },
      %{
        name: "Invoice",
        code: 23
      },
      %{
        name: "Fees",
        code: 24
      },
      %{
        name: "Settlement",
        code: 25
      },
      %{
        name: "Gift",
        code: 26
      },
      %{
        name: "Donation",
        code: 27
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
