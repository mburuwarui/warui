defmodule Warui.Treasury.Helpers.Seeders.TransferTypes do
  alias Warui.Treasury.TransferType
  require Ash.Query

  def seed(tenant) do
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
        if !Ash.exists?(
             TransferType
             |> Ash.Query.filter(name == ^transfer_type.name)
             |> Ash.Query.set_tenant(tenant)
           ) do
          TransferType
          |> Ash.Changeset.for_create(:create, transfer_type, tenant: tenant)
          |> Ash.create!()
        end
      end
    )
  end
end
