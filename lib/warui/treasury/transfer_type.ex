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
    defaults [:read, create: [], update: []]
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string do
      allow_nil? false
    end

    attribute :code, :integer do
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    has_many :transfers, Warui.Treasury.Transfer
  end
end
