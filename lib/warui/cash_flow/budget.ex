defmodule Warui.CashFlow.Budget do
  alias Warui.Treasury.Helpers.TypeCache

  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.CashFlow,
    data_layer: AshPostgres.DataLayer,
    notifiers: [Ash.Notifier.PubSub],
    extensions: [AshOban, AshGraphql.Resource, AshJsonApi.Resource, AshAdmin.Resource]

  admin do
    actor? true
  end

  postgres do
    table "budgets"
    repo Warui.Repo
  end

  oban do
    triggers do
      trigger :check_budget_variance do
        action :analyze_variance
        queue :budget_monitoring
        lock_for_update? false
        list_tenants fn -> TypeCache.list_tenants() end
        worker_module_name Warui.CashFlow.Budget.Workers.BudgetMonitoring
        scheduler_module_name Warui.CashFlow.Budget.Schedulers.BudgetMonitoring
        where expr(needs_analysis)
      end
    end

    triggers do
      trigger :monthly_budget_rollover do
        action :rollover_budget
        queue :budget_management
        lock_for_update? false
        list_tenants fn -> TypeCache.list_tenants() end
        worker_module_name Warui.CashFlow.Budget.Workers.BudgetRollover
        scheduler_module_name Warui.CashFlow.Budget.Schedulers.BudgetRollover
        where expr(needs_rollover)
      end
    end
  end

  json_api do
    type "budget"
  end

  graphql do
    type :budget
  end

  actions do
    default_accept [
      :name,
      :description,
      :total_amount,
      :period_start,
      :period_end,
      :budget_type,
      :status,
      :variance_threshold,
      :variance_check_enabled,
      :budget_owner_id,
      :budget_ledger_id,
      :budget_account_id
    ]

    defaults [:create, :read]

    create :rollover_budget do
      accept []
      argument :previous_budget_id, :uuid, allow_nil?: false

      change Warui.CashFlow.Budget.Changes.RolloverBudget
    end

    update :update do
      require_atomic? false

      accept [
        :name,
        :description,
        :total_amount,
        :period_start,
        :period_end,
        :budget_type,
        :status,
        :variance_threshold,
        :variance_check_enabled
      ]
    end

    update :analyze_variance do
      transaction? false
      require_atomic? false
      change Warui.CashFlow.Budget.Changes.AnalyzeVariance
    end
  end

  pub_sub do
    module WaruiWeb.Endpoint
    prefix "cash_flow"

    publish_all :create, ["budgets", :budget_owner_id] do
      transform & &1.data
    end

    publish_all :update, ["budgets", :budget_owner_id] do
      transform & &1.data
    end

    publish :rollover_budget, ["budgets", "rollover", :id] do
      transform & &1.data
    end

    publish :analyze_variance, ["budgets", "variance", :id] do
      transform & &1.data
    end
  end

  preparations do
    prepare Warui.Preparations.SetTenant
  end

  changes do
    change Warui.Changes.SetTenant
    change Warui.Changes.Slugify
  end

  multitenancy do
    strategy :context
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :slug, :string

    attribute :description, :string

    attribute :total_amount, :money do
      allow_nil? false
    end

    attribute :period_start, :date do
      allow_nil? false
    end

    attribute :period_end, :date do
      allow_nil? false
    end

    attribute :budget_type, :atom do
      constraints one_of: [:monthly, :quaterly, :yearly]
      default :monthly
    end

    attribute :status, :atom do
      constraints one_of: [:draft, :active, :rolled_over, :completed, :suspended]
      default :draft
    end

    attribute :variance_threshold, :decimal do
      default "0.10"
    end

    attribute :variance_check_enabled, :boolean do
      default true
    end

    timestamps()
  end

  relationships do
    belongs_to :owner, Warui.Accounts.User do
      source_attribute :budget_owner_id
      allow_nil? false
    end

    belongs_to :ledger, Warui.Treasury.Ledger do
      source_attribute :budget_ledger_id
      allow_nil? false
    end

    belongs_to :account, Warui.Treasury.Account do
      source_attribute :budget_account_id
      allow_nil? false
    end
  end

  calculations do
    calculate :needs_analysis, :boolean do
      calculation expr(
                    status == :active and
                      variance_check_enabled and
                      updated_at <= ago(1, :day) and
                      variance_threshold > 0
                  )
    end

    calculate :needs_rollover, :boolean do
      calculation expr(
                    total_amount > 0 and
                      ((budget_type == :monthly and
                          today() > period_end) or
                         (budget_type == :quarterly and
                            today() > period_end) or
                         (budget_type == :yearly and
                            today() > period_end))
                  )
    end
  end
end
