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
    user = changeset.context.private.actor

    IO.inspect(user, label: "user_for_account_creation")

    account_type = TypeCache.get_account_type_by_name("Checking", user)

    params = %{
      name: "Default Account",
      account_owner_id: user.id,
      account_ledger_id: ledger.id,
      account_type_id: account_type.id
    }

    Warui.Treasury.Account
    |> Ash.Changeset.for_create(:create, params, actor: user)
    |> Ash.create!()

    {:ok, ledger}
  end
end
