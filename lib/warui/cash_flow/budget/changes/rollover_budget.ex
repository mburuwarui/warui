defmodule Warui.CashFlow.Budget.Changes.RolloverBudget do
  use Ash.Resource.Change
  alias Warui.CashFlow.Budget

  def change(changeset, _opts, _context) do
    changeset
    |> Ash.Changeset.before_action(&create_new_budget_from_previous/2)
    |> Ash.Changeset.after_action(&update_previous_budget_status/2)
  end

  defp create_new_budget_from_previous(changeset, _opts) do
    previous_budget_id = Ash.Changeset.get_argument(changeset, :previous_budget_id)
    next_period_start = Date.utc_today()
    user = changeset.context.private.actor

    {:ok, previous_budget} =
      Budget
      |> Ash.get!(previous_budget_id, actor: user)

    period_end = calculate_period_end(next_period_start, previous_budget.budget_type)

    budget_params = %{
      name: previous_budget.name,
      description: previous_budget.description,
      total_amount: previous_budget.total_amount,
      period_start: next_period_start,
      period_end: period_end,
      budget_type: previous_budget.budget_type,
      status: previous_budget.status,
      variance_threshold: previous_budget.variance_threshold,
      variance_check_enabled: previous_budget.variance_check_enabled,
      budget_owner_id: previous_budget.budget_owner_id,
      budget_ledger_id: previous_budget.budget_ledger_id,
      budget_account_id: previous_budget.budget_account_id
    }

    Budget
    |> Ash.Changeset.for_create(:create, budget_params, actor: user)
    |> Ash.create!()

    previous_budget_changeset =
      previous_budget
      |> Ash.Changeset.for_update(:update, %{status: :rolled_over}, actor: user)

    previous_budget_changeset
  end

  defp calculate_period_end(start_date, :monthly), do: Date.end_of_month(start_date)
  defp calculate_period_end(start_date, :quarterly), do: Date.add(start_date, 90)
  defp calculate_period_end(start_date, :yearly), do: Date.add(start_date, 365)

  defp update_previous_budget_status(changeset, budget) do
    {:ok, _} =
      changeset
      |> Ash.update()

    {:ok, budget}
  end
end
