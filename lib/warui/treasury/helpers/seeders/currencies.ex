defmodule Warui.Treasury.Helpers.Seeders.Currencies do
  alias Warui.Treasury.Currency
  require Ash.Query

  def seed(user) do
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
        name: "Tanzania Shilling",
        symbol: "TZS",
        scale: 2
      },
      %{
        name: "Uganda Shilling",
        symbol: "UGX",
        scale: 2
      }
    ]

    Enum.each(
      default_currencies,
      fn currency ->
        exists? =
          Currency
          |> Ash.Query.filter(name == ^currency.name)
          |> Ash.exists?(actor: user)

        if !exists? do
          Currency
          |> Ash.Changeset.for_create(:create, currency, actor: user)
          |> Ash.create!()
        end
      end
    )
  end
end
