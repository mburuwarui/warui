defmodule Warui.Accounts.Permission do
  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  postgres do
    table "permissions"
    repo Warui.Repo
  end

  json_api do
    type "permission"
  end

  graphql do
    type :permission
  end

  actions do
    defaults [:create, :read, :destroy, :update]
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :action, :string do
      allow_nil? false
    end

    attribute :resource, :string do
      allow_nil? false
    end

    timestamps()
  end
end
