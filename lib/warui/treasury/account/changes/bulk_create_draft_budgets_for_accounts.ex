defmodule Warui.Accounts.User.Changes.BulkCreateDraftBudgetsForAccounts do
  @moduledoc """
  Creates draft budgets for users in bulk after the user resources are created.
  Handles tenant-specific accounts where tenant is passed as an argument.
  Optimized for batch operations using Ash.Resource.Change batch callbacks.
  """

  alias Warui.Treasury.Helpers.TypeCache
  use Ash.Resource.Change

  @doc """
  Sets up the after_transaction hook for single record changes.
  This will be called when not using bulk operations.

  Options:
  * :user - The owner of the account
  * :asset_scale - The asset scale for the account (default: 2)
  """

  def batch_change(changesets, _opts, _context) do
    Enum.map(changesets, fn changeset ->
      Ash.Changeset.after_transaction(changeset, &create_draft_budget_for_account/2)
    end)
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
