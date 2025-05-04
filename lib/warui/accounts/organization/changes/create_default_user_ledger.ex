defmodule Warui.Accounts.Organization.Changes.CreateDefaultLedgerForUser do
  @moduledoc """
  Create a default Ledger and Account for a user
  """
  use Ash.Resource.Change
  alias Warui.Treasury.Helpers.TypeCache
  alias Warui.Treasury.Helpers.Seeder

  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, &create_default_user_ledger/2)
  end

  defp create_default_user_ledger(_changeset, organization) do
    opts = [authorize?: false]

    {:ok, user} = Ash.get(Warui.Accounts.User, organization.owner_user_id, opts)

    Seeder.seed_treasury_types(user)
    TypeCache.init_caches(user)
    asset_type_id = TypeCache.asset_type_id("Cash", user)
    currency_id = TypeCache.currency_id("Kenya Shilling", user)

    ledger_attrs = %{
      name: "Personal",
      asset_type_id: asset_type_id,
      currency_id: currency_id,
      ledger_owner_id: user.id
    }

    Ash.create!(Warui.Treasury.Ledger, ledger_attrs, actor: user)

    {:ok, organization}
  end
end
