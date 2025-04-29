# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Warui.Repo.insert!(%Warui.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

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

Ash.Seed.seed!(Warui.Treasury.Currency, default_currencies)
