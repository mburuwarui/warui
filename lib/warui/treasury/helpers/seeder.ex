defmodule Warui.Treasury.Helpers.Seeder do
  @moduledoc """
  Helper for seeding default treasury types
  """

  alias Warui.Treasury.Helpers.Seeders.Currencies
  alias Warui.Treasury.Helpers.Seeders.AssetTypes
  alias Warui.Treasury.Helpers.Seeders.AccountTypes
  alias Warui.Treasury.Helpers.Seeders.TransferTypes

  @doc """
  Seed default treasury types
  """
  def seed_treasury_types(tenant) do
    Currencies.seed(tenant)
    AssetTypes.seed(tenant)
    AccountTypes.seed(tenant)
    TransferTypes.seed(tenant)
  end
end
