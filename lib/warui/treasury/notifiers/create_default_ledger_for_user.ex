defmodule Warui.Treasury.Notifiers.CreateDefaultLedgerForUser do
  @moduledoc """
  Create a default Ledger and Account for a user
  """
  alias Warui.Treasury.Helpers.TypeCache
  alias Ash.Notifier.Notification
  use Ash.Notifier

  def notify(%Notification{data: organization, action: %{name: :create}}) do
    create_default_ledger_for_user(organization)
  end

  def notify(%Notification{} = _notification), do: :ok

  defp create_default_ledger_for_user(organization) do
    currency = TypeCache.get_currency_by_name("Kenya Shilling", organization.domain)
    asset_type = TypeCache.get_asset_type_by_name("Cash", organization.domain)

    ledger_attrs = %{
      name: "Personal",
      owner_id: organization.owner_user_id,
      currency_id: currency.id,
      asset_type_id: asset_type.id
    }

    Ash.create!(Warui.Treasury.Ledger, ledger_attrs)
  end
end
