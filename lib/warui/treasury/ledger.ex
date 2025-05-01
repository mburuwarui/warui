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
    default_accept [:name, :slug, :description, :ledger_owner_id, :currency_id, :asset_type_id]
    defaults [:read, :destroy]

    create :create do
      primary? true
      change Warui.Treasury.Ledger.Changes.CreateDefaultUserAccount
    end

    create :create_with_account do
      description "Create a Ledger with a default account"
      argument :account_attrs, :map, allow_nil?: false
      change manage_relationship(:account_attrs, :accounts, type: :create)
    end

    update :update do
      require_atomic? false
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
      public? true
    end

    attribute :slug, :string do
      public? true
    end

    attribute :description, :string do
      description "A description of the ledger"
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :owner, Warui.Accounts.User do
      source_attribute :ledger_owner_id
      allow_nil? true
    end

    belongs_to :currency, Warui.Treasury.Currency do
      source_attribute :currency_id
      allow_nil? false
    end

    belongs_to :asset_type, Warui.Treasury.AssetType do
      source_attribute :asset_type_id
      allow_nil? false
    end

    has_many :accounts, Warui.Treasury.Account do
      destination_attribute :account_ledger_id
    end

    has_many :transfers, Warui.Treasury.Transfer do
      destination_attribute :transfer_ledger_id
    end

    many_to_many :members, Warui.Accounts.User do
      through Warui.Treasury.UserLedger
      source_attribute_on_join_resource :ledger_id
      destination_attribute_on_join_resource :user_id
    end
  end
end
