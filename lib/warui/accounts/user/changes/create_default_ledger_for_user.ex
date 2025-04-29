defmodule Warui.Accounts.User.Changes.CreateDefaultLedgerForUser do
  @moduledoc """
  Create a default Ledger and Account for a user
  """
  alias Warui.Treasury.Helpers.TypeCache

  use Ash.Resource.Change

  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, &create_default_ledger_for_user/2)
  end

  defp create_default_ledger_for_user(_changeset, user) do
    currency = TypeCache.get_currency_by_name("Kenya Shilling", user.current_organization)
    asset_type = TypeCache.get_asset_type_by_name("Cash", user.current_organization)

    _params = %{
      name: "Personal",
      owner_id: user.id,
      currency_id: currency.id,
      asset_type_id: asset_type.id
    }
  end
end
