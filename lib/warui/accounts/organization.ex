defmodule Warui.Accounts.Organization do
  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  postgres do
    table "organizations"
    repo Warui.Repo
  end

  json_api do
    type "organization"
  end

  graphql do
    type :organization
  end

  actions do
    defaults [:read, create: [:name, :domain, :description]]
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :domain, :string do
      allow_nil? false
      public? true
    end

    attribute :description, :string do
      public? true
    end

    timestamps()
  end

  relationships do
    belongs_to :user, Warui.Accounts.User do
      public? true
    end
  end
end
