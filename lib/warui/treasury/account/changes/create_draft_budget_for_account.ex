defmodule Warui.Accounts.User.Changes.CreateDraftBudgetForAccount do
  alias Warui.Treasury.Helpers.TypeCache
  use Ash.Resource.Change

  @doc """
  Creates a draft budget for a user account after the user resource is created.

  Options: 
  * :user - The owner of the account
  * :asset_scale - The asset scale for the account (default: 2)
  """
  def change(changeset, _opts, _context) do
    Ash.Changeset.after_transaction(changeset, &create_draft_budget_for_account/2)
  end

  defp create_draft_budget_for_account(changeset, {:ok, account}) do
    user = changeset.context.private.actor
    currency = TypeCache.ledger_currency(account.account_ledger_id, user)

    budget_attrs = %{
      name: "#{account.name} Budget",
      total_amount: Money.new!(currency.symbol, 0),
      period_start: Date.utc_today(),
      period_end: Date.end_of_month(Date.utc_today()),
      budget_owner_id: account.account_owner_id,
      budget_ledger_id: account.account_ledger_id,
      budget_account_id: account.id
    }

    {:ok, _budget} =
      Warui.CashFlow.Budget
      |> Ash.Changeset.for_create(:create, budget_attrs, actor: user)
      |> Ash.create()

    {:ok, account}
  end
end
