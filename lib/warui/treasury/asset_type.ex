defmodule Warui.Treasury.AssetType do
  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.Treasury,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  postgres do
    table "asset_types"
    repo Warui.Repo
  end

  json_api do
    type "asset_type"
  end

  graphql do
    type :asset_type
  end

  actions do
    default_accept [:name, :description, :code, :currency_id]
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

    attribute :description, :string

    attribute :code, :integer do
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    belongs_to :currency, Warui.Treasury.Currency do
      source_attribute :currency_id
      allow_nil? false
    end

    has_many :assets, Warui.Treasury.Asset do
      destination_attribute :asset_type_id
    end
  end

  identities do
    identity :unique_name, [:name]
    identity :unique_code, [:code]
  end
end
