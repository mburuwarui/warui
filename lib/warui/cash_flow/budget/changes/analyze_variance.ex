defmodule Warui.CashFlow.Budget.Changes.AnalyzeVariance do
  use Ash.Resource.Change
  alias Warui.Treasury.Helpers.TypeCache
  alias Warui.Treasury.Helpers.MoneyConverter
  alias Warui.Treasury.Helpers.TigerbeetleService

  def change(changeset, _opts, _context) do
    changeset
    |> Ash.Changeset.after_action(&perform_variance_analysis/2)
  end

  defp perform_variance_analysis(changeset, budget) do
    # Calculate actual spending vs budget
    case calculate_budget_variance(budget) do
      {:ok, variance_data} ->
        # If variance exceeds threshold, could trigger notifications or other actions
        if variance_exceeds_threshold?(variance_data, budget.variance_threshold) do
          handle_variance_threshold_exceeded(budget, variance_data)
        end

        # Update the budget's last analysis timestamp
        user = changeset.context.private.actor
        update_analysis_timestamp(budget, user)

      {:error, error} ->
        Ash.Changeset.add_error(changeset, error)

        {:ok, budget}
    end
  end

  defp calculate_budget_variance(budget) do
    try do
      actual_spending = get_actual_spending(budget)
      budgeted_amount = Money.to_decimal(budget.total_amount)

      variance_amount = Decimal.sub(actual_spending, budgeted_amount)

      variance_percentage =
        if Decimal.compare(budgeted_amount, 0) == :gt do
          Decimal.div(variance_amount, budgeted_amount)
        else
          Decimal.new(0)
        end

      {:ok,
       %{
         budgeted_amount: budgeted_amount,
         actual_spending: actual_spending,
         variance_amount: variance_amount,
         variance_percentage: variance_percentage
       }}
    rescue
      error ->
        {:error, error}
    end
  end

  defp get_actual_spending(budget) do
    budget = budget |> Ash.load!([:owner])
    user = budget.owner
    organization_owner = user

    filter = %{
      account_id: budget.budget_account_id,
      timestamp_min: DateTime.new!(budget.period_start, ~T[00:00:00]),
      timestamp_max: DateTime.new!(budget.period_end, ~T[23:59:59])
    }

    asset_scale = TypeCache.ledger_asset_scale(budget.budget_ledger_id, user)

    case TigerbeetleService.get_account_transfers(filter, user, organization_owner) do
      {:ok, transfers} ->
        transfers
        |> Enum.map(fn transfer ->
          MoneyConverter.tigerbeetle_amount_to_money(
            transfer.amount,
            budget.total_amount.currency,
            asset_scale
          )
          |> Money.to_decimal()
        end)
        |> Enum.reduce(Decimal.new("0"), &Decimal.add/2)

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp variance_exceeds_threshold?(variance_data, threshold) do
    variance_percentage = Decimal.abs(variance_data.variance_percentage)
    Decimal.compare(variance_percentage, threshold) == :gt
  end

  defp handle_variance_threshold_exceeded(budget, variance_data) do
    Phoenix.PubSub.broadcast(
      Warui.PubSub,
      "budget:#{budget.id}",
      {:variance_threshold_exceeded, budget, variance_data}
    )
  end

  defp update_analysis_timestamp(budget, user) do
    {:ok, updated_budget} =
      budget
      |> Ash.Changeset.for_update(:update, %{}, actor: user)
      |> Ash.update()

    {:ok, updated_budget}
  end
end
