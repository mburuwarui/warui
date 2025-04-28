defmodule Warui.Treasury.Currency do
  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.Treasury,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  postgres do
    table "currencies"
    repo Warui.Repo
  end

  json_api do
    type "currency"
  end

  graphql do
    type :currency
  end

  actions do
    default_accept [:name, :symbol, :code]
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

    attribute :symbol, :string do
      allow_nil? false
    end

    attribute :code, :integer do
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    has_many :ledgers, Warui.Treasury.Ledger do
      destination_attribute :currency_id
    end
  end
end
