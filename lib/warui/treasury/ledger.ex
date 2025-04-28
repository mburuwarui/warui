defmodule Warui.Treasury.Ledger do
  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.Treasury,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource],
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "ledgers"
    repo Warui.Repo
  end

  json_api do
    type "ledger"
  end

  graphql do
    type :ledger
  end

  actions do
    default_accept [:name, :slug, :description, :ledger_type, :owner_id]
    defaults [:create, :read, :update, :destroy]
  end

  multitenancy do
    strategy :context
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :slug, :string do
      public? true
    end

    attribute :description, :string do
      public? true
    end

    attribute :ledger_type, :atom do
      constraints one_of: [:KES, :USD, :EUR, :BTC, :Test]
      default :KES
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    belongs_to :owner, Warui.Accounts.User do
      source_attribute :owner_id
      allow_nil? false
    end

    many_to_many :members, Warui.Accounts.User do
      through Warui.Treasury.UserLedger
      source_attribute_on_join_resource :ledger_id
      destination_attribute_on_join_resource :user_id
    end
  end
end
