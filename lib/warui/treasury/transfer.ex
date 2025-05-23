defmodule Warui.Treasury.Transfer do
  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.Treasury,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource, AshAdmin.Resource]

  admin do
    actor? true
  end

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
      :transfer_owner_id,
      :transfer_ledger_id,
      :transfer_type_id,
      :from_account_id,
      :to_account_id
    ]

    defaults [:read]

    create :create do
      primary? true

      argument :organization_owner, :map, allow_nil?: false
      argument :flags, :map

      change Warui.Treasury.Transfer.Changes.CreateTigerbeetleTransfer
      change set_attribute(:status, :settled)
    end

    create :bulk_create_with_tigerbeetle_transfer do
      argument :organization_owner, :map, allow_nil?: false
      argument :flags, :map

      change Warui.Treasury.Transfer.Changes.BulkCreateTigerbeetleTransfer
      change set_attribute(:status, :settled)
    end

    update :post_pending_transfer do
      primary? true
      require_atomic? false

      accept [:transfer_ledger_id, :transfer_type_id, :status, :description, :settled_at]
      argument :organization_owner, :map, allow_nil?: false
      argument :flags, :map

      change Warui.Treasury.Transfer.Changes.PostPendingTigerbeetleTransfer
      change set_attribute(:settled_at, &DateTime.utc_now/0)
      change set_attribute(:status, :settled)
    end

    update :void_pending_transfer do
      require_atomic? false

      accept [:transfer_ledger_id, :transfer_type_id, :status, :description]
      argument :organization_owner, :map, allow_nil?: false
      argument :flags, :map

      change Warui.Treasury.Transfer.Changes.VoidPendingTigerbeetleTransfer
      change set_attribute(:voided_at, &DateTime.utc_now/0)
      change set_attribute(:status, :voided)
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

    attribute :amount, :money do
      allow_nil? false
    end

    attribute :status, :atom do
      constraints one_of: [:pending, :settled, :voided]
      default :pending
      allow_nil? false
    end

    attribute :description, :string do
      description "A description of the transfer"
    end

    attribute :settled_at, :utc_datetime_usec do
      description "The date and time the transfer was settled"
    end

    attribute :voided_at, :utc_datetime_usec do
      description "The date and time the transfer was voided"
    end

    timestamps()
  end

  relationships do
    belongs_to :owner, Warui.Accounts.User do
      source_attribute :transfer_owner_id
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
      source_attribute :transfer_ledger_id
      allow_nil? false
    end

    belongs_to :transfer_type, Warui.Treasury.TransferType do
      source_attribute :transfer_type_id
      allow_nil? false
    end
  end
end
