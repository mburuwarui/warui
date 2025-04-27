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
    defaults [:read, :destroy, create: [], update: []]
  end

  attributes do
    uuid_v7_primary_key :id

    timestamps()
  end

  relationships do
    belongs_to :user, Warui.Accounts.User do
      public? true
    end

    belongs_to :organization, Warui.Accounts.Organization do
      public? true
    end
  end
end
