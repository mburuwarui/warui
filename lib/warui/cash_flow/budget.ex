defmodule Warui.CashFlow.Budget do
  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.CashFlow,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

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
    defaults [:read, create: [], update: []]
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

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
      allow_nil? false
    end

    attribute :status, :atom do
      allow_nil? false
    end

    attribute :variance_threshold, :decimal do
      allow_nil? false
    end

    attribute :variance_check_enabled, :boolean do
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    belongs_to :user, Warui.Accounts.User
    belongs_to :ledger, Warui.Treasury.Ledger
    belongs_to :account, Warui.Treasury.Account
  end
end
