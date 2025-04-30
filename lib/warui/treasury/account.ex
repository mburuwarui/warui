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
    default_accept [:name, :slug, :description, :account_type_id, :owner_id, :ledger_id]
    defaults [:read, update: [:slug, :description, :status]]

    create :create do
      primary? true

      argument :tenant, :string, allow_nil?: false

      change Warui.Accounts.User.Changes.CreateTigerBeetleAccount

      change relate_actor(:owner)
    end

    update :freeze_account do
      accept [:status, :description]

      change set_attribute(:status, :frozen)
    end

    update :unfreeze_account do
      accept [:status, :description]
      change set_attribute(:status, :active)
    end

    update :close_account do
      accept [:status, :description]
      argument :tenant, :string, allow_nil?: false

      change Warui.Accounts.User.Changes.CloseTigerBeetleAccount
      change set_attribute(:status, :closed)
    end

    update :reopen_account do
      accept [:status, :description]
      argument :tenant, :string, allow_nil?: false

      change Warui.Accounts.User.Changes.ReopenTigerBeetleAccount
      change set_attribute(:status, :active)
    end
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

    attribute :description, :string do
      description "A description of the account"
    end

    attribute :status, :atom do
      constraints one_of: [:active, :closed, :frozen]
      default :active
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    belongs_to :owner, Warui.Accounts.User do
      source_attribute :owner_id
      allow_nil? false
    end

    belongs_to :ledger, Warui.Treasury.Ledger do
      source_attribute :ledger_id
      allow_nil? false
    end

    belongs_to :account_type, Warui.Treasury.AccountType do
      source_attribute :account_type_id
      allow_nil? false
    end

    has_many :outgoing_transfers, Warui.Treasury.Transfer do
      destination_attribute :from_account_id
    end

    has_many :incoming_transfers, Warui.Treasury.Transfer do
      destination_attribute :to_account_id
    end
  end
end
