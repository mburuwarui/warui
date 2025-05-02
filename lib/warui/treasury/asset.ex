defmodule Warui.Treasury.Asset do
  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.Treasury,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  postgres do
    table "assets"
    repo Warui.Repo
  end

  json_api do
    type "asset"
  end

  graphql do
    type :asset
  end

  actions do
    default_accept [:name, :description, :value, :currency_id, :asset_type_id]
    defaults [:create, :read, :destroy]

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

    attribute :value, :money do
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    belongs_to :currency, Warui.Treasury.Currency do
      source_attribute :currency_id
      allow_nil? false
    end

    belongs_to :asset_type, Warui.Treasury.AssetType do
      source_attribute :asset_type_id
      allow_nil? false
    end
  end
end
