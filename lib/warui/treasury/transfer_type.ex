defmodule Warui.Treasury.TransferType do
  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.Treasury,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  postgres do
    table "transfer_types"
    repo Warui.Repo
  end

  json_api do
    type "transfer_type"
  end

  graphql do
    type :transfer_type
  end

  actions do
    default_accept [:name, :code, :description]
    defaults [:create, :read]

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

    attribute :name, :string do
      allow_nil? false
    end

    attribute :description, :string do
      description "A description of the transfer type"
    end

    attribute :code, :integer do
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    has_many :transfers, Warui.Treasury.Transfer do
      destination_attribute :transfer_type_id
    end
  end

  identities do
    identity :unique_name, [:name]
    identity :unique_code, [:code]
  end
end
