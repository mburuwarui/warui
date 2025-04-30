defmodule Warui.Treasury.Ledger.Changes.CreateDefaultUserAccount do
  @moduledoc """
  Create a default Ledger and Account for a user
  """
  use Ash.Resource.Change
  alias Warui.Treasury.Helpers.TypeCache

  def change(changeset, _opts, _context) do
    Ash.Changeset.after_action(changeset, &create_default_user_account/2)
  end

  defp create_default_user_account(changeset, ledger) do
    tenant = Ash.Changeset.get_argument(changeset, :tenant)

    account_type = TypeCache.get_account_type_by_name("Checking", tenant)

    params = %{
      name: "Default Account",
      owner_id: ledger.owner_id,
      ledger_id: ledger.id,
      account_type_id: account_type.id
    }

    Warui.Treasury.Account
    |> Ash.Changeset.for_create(:create, params)
    |> Ash.Changeset.set_tenant(tenant)
    |> Ash.create!()

    {:ok, ledger}
  end
end
