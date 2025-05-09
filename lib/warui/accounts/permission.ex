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
    default_accept [:action, :resource]
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

  relationships do
    many_to_many :groups, Warui.Accounts.Group do
      through Warui.Accounts.GroupPermission
      source_attribute_on_join_resource :permission_id
      destination_attribute_on_join_resource :group_id
    end
  end
end
