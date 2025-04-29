defmodule Warui.Treasury.Helpers.Seeders.TransferTypes do
  alias Warui.Treasury.TransferType
  use Nebulex.Caching
  alias Warui.Cache
  require Ash.Query

  @ttl :timer.hours(24)

  def seed do
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
             |> Ash.Query.set_tenant("system_organization")
           ) do
          TransferType
          |> Ash.Changeset.for_create(:create, transfer_type, tenant: "system_organization")
          |> Ash.create!()

          Cache.put({:transfer_type, :name, transfer_type.name}, transfer_type, ttl: @ttl)
          Cache.put({:transfer_type, :code, transfer_type.code}, transfer_type, ttl: @ttl)
        end
      end
    )
  end
end
