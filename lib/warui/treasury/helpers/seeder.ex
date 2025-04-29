defmodule Warui.Treasury.Helpers.Seeder do
  @moduledoc """
  Helper for seeding default treasury types
  """

  alias Warui.Treasury.Currency
  require Ash.Query

  @doc """
  Seed default treasury types
  """
  def seed do
    seed_currencies()
  end

  def seed_currencies do
    default_currencies = [
      %{
        name: "Kenya Shilling",
        symbol: "KES",
        scale: 2
      },
      %{
        name: "US Dollar",
        symbol: "USD",
        scale: 2
      },
      %{
        name: "Euro",
        symbol: "EUR",
        scale: 2
      },
      %{
        name: "Pound Sterling",
        symbol: "GBP",
        scale: 2
      },
      %{
        name: "Bitcoin",
        symbol: "BTC",
        scale: 8
      },
      %{
        name: "Stock",
        symbol: "STK",
        scale: 2
      },
      %{
        name: "Title Deed",
        symbol: "TD",
        scale: 2
      }
    ]

    Enum.each(
      default_currencies,
      fn currency ->
        if !Ash.exists?(
             Currency
             |> Ash.Query.filter(name == ^currency.name)
             |> Ash.Query.set_tenant("system_organization")
           ) do
          Currency
          |> Ash.Changeset.for_create(:create, currency, tenant: "system_organization")
          |> Ash.create!()
        end
      end
    )
  end
end
