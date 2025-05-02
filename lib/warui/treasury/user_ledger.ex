defmodule Warui.Treasury.UserLedger do
  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.Treasury,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  postgres do
    table "user_ledgers"
    repo Warui.Repo
  end

  json_api do
    type "user_ledger"
  end

  graphql do
    type :user_ledger
  end

  resource do
    require_primary_key? false
  end

  actions do
    default_accept [:user_id, :ledger_id]
    defaults [:create, :read, :destroy]

    update :update do
      require_atomic? false
    end
  end

  preparations do
    prepare Warui.Preparations.SetTenant
  end

  changes do
    change Warui.Changes.SetTenant
  end

  multitenancy do
    strategy :context
  end

  attributes do
    uuid_v7_primary_key :id

    timestamps()
  end

  relationships do
    belongs_to :user, Warui.Accounts.User do
      source_attribute :user_id
      public? true
    end

    belongs_to :ledger, Warui.Treasury.Ledger do
      source_attribute :ledger_id
      public? true
    end
  end

  identities do
    identity :unique_user_ledger, [:user_id, :ledger_id]
  end
end
