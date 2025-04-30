defmodule Warui.Treasury.Ledger.Notifiers.CreateDefaultLedgerForUser do
  @moduledoc """
  Create a default Ledger and Account for a user
  """
  alias Warui.Treasury.Helpers.Seeder
  alias Warui.Treasury.Helpers.TypeCache
  alias Ash.Notifier.Notification
  use Ash.Notifier

  def notify(%Notification{data: organization, action: %{name: :create}}) do
    create_default_ledger_for_user(organization)
  end

  def notify(%Notification{} = _notification), do: :ok

  defp create_default_ledger_for_user(organization) do
    Seeder.seed_treasury_types(organization.domain)
    TypeCache.init_caches(organization.domain)
    asset_type = TypeCache.get_asset_type_by_name("Cash", organization.domain)
    currency = TypeCache.get_currency_by_name("Kenya Shilling", organization.domain)

    ledger_attrs = %{
      name: "Personal",
      owner_id: organization.owner_user_id,
      asset_type_id: asset_type.id,
      currency_id: currency.id,
      tenant: organization.domain
    }

    Ash.create!(Warui.Treasury.Ledger, ledger_attrs, tenant: organization.domain)
  end
end
