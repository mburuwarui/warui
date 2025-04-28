defmodule Warui.Treasury.Transfer do
  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.Treasury,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  postgres do
    table "transfers"
    repo Warui.Repo
  end

  json_api do
    type "transfer"
  end

  graphql do
    type :transfer
  end

  actions do
    default_accept [
      :amount,
      :status,
      :description,
      :settled_at,
      :owner_id,
      :transfer_type_id,
      :from_account_id,
      :to_account_id
    ]

    defaults [:create, :read, update: [:status, :description, :settled_at]]
  end

  multitenancy do
    strategy :context
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :amount, :decimal do
      allow_nil? false
    end

    # attribute :transfer_type, :atom do
    #   constraints one_of: [
    #                 :payment,
    #                 :subscription,
    #                 :invoice,
    #                 :fees,
    #                 :settlement,
    #                 :gift,
    #                 :donation
    #               ]
    #
    #   default :payment
    #   allow_nil? false
    # end

    attribute :status, :atom do
      constraints one_of: [:pending, :settled, :failed]
      default :pending
      allow_nil? false
    end

    attribute :description, :string do
      description "A description of the transfer"
    end

    attribute :settled_at, :utc_datetime_usec do
      description "The date and time the transfer was settled"
    end

    timestamps()
  end

  relationships do
    belongs_to :owner, Warui.Accounts.User do
      source_attribute :owner_id
      allow_nil? false
    end

    belongs_to :from_account, Warui.Treasury.Account do
      source_attribute :from_account_id
      allow_nil? false
    end

    belongs_to :to_account, Warui.Treasury.Account do
      source_attribute :to_account_id
      allow_nil? false
    end

    belongs_to :ledger, Warui.Treasury.Ledger do
      source_attribute :ledger_id
      allow_nil? false
    end

    belongs_to :transfer_type, Warui.Treasury.TransferType do
      source_attribute :transfer_type_id
      allow_nil? false
    end
  end
end
