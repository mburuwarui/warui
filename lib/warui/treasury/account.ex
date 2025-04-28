defmodule Warui.Treasury.Account do
  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.Treasury,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  postgres do
    table "accounts"
    repo Warui.Repo
  end

  json_api do
    type "account"
  end

  graphql do
    type :account
  end

  actions do
    default_accept [:name, :slug, :description, :type]
    defaults [:create, :read, :update, :destroy]
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

    attribute :type, :atom do
      allow_nil? false
    end

    attribute :status, :atom do
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    belongs_to :owner, Warui.Accounts.User
    belongs_to :ledger, Warui.Treasury.Ledger
  end
end
