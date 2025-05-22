defmodule Warui.CashFlow.Budget do
  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.CashFlow,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshOban, AshGraphql.Resource, AshJsonApi.Resource],
    notifiers: [Ash.Notifier.PubSub]

  postgres do
    table "budgets"
    repo Warui.Repo
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
      :slug,
      :description,
      :total_amount,
      :period_start,
      :period_end,
      :budget_type,
      :status,
      :variance_threshold,
      :variance_check_enabled
    ]

    defaults [:create, :read]

    update :update do
      require_atomic? false

      accept [
        :name,
        :slug,
        :description,
        :period_end,
        :budget_type,
        :status,
        :variance_threshold,
        :variance_check_enabled
      ]
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
      allow_nil? false
    end

    attribute :status, :atom do
      constraints one_of: [:draft, :active, :completed, :suspended]
      default :draft
      allow_nil? false
    end

    attribute :variance_threshold, :decimal do
      default "0.10"
      allow_nil? false
    end

    attribute :variance_check_enabled, :boolean do
      allow_nil? false
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
end
