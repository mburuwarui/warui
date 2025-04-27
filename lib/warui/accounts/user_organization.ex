defmodule Warui.Accounts.UserOrganization do
  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  postgres do
    table "user_organizations"
    repo Warui.Repo
  end

  json_api do
    type "user_organization"
  end

  graphql do
    type :user_organization
  end

  actions do
    default_accept [:user_id, :organization_id]
    defaults [:create, :read, :update, :destroy]
  end

  attributes do
    uuid_v7_primary_key :id

    timestamps()
  end

  relationships do
    belongs_to :user, Warui.Accounts.User do
      source_attribute :user_id
      public? true
    end

    belongs_to :organization, Warui.Accounts.Organization do
      source_attribute :organization_id
      public? true
    end
  end

  identities do
    identity :unique_user_organization, [:user_id, :organization_id]
  end
end
