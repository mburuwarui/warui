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
    asset_type = TypeCache.get_asset_type_by_name("Cash", user)
    currency = TypeCache.get_currency_by_name("Kenya Shilling", user)

    IO.inspect(currency, label: "currency")

    ledger_attrs = %{
      name: "Personal",
      asset_type_id: asset_type.id,
      currency_id: currency.id,
      ledger_owner_id: user.id
    }

    Ash.create!(Warui.Treasury.Ledger, ledger_attrs, actor: user)

    {:ok, organization}
  end
end
