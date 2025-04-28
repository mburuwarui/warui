defmodule Warui.Treasury.AccountType do
  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.Treasury,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  postgres do
    table "account_types"
    repo Warui.Repo
  end

  json_api do
    type "account_type"
  end

  graphql do
    type :account_type
  end

  actions do
    default_accept [:name, :code]
    defaults [:read, create: [], update: []]
  end

  multitenancy do
    strategy :context
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :code, :integer do
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    has_many :accounts, Warui.Treasury.Account do
      destination_attribute :account_type_id
    end
  end
end
