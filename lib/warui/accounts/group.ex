defmodule Warui.Accounts.Group do
  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  postgres do
    table "groups"
    repo Warui.Repo
  end

  json_api do
    type "group"
  end

  graphql do
    type :group
  end

  actions do
    default_accept [:name, :description]
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

    attribute :description, :string do
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    many_to_many :users, Warui.Accounts.User do
      through Warui.Accounts.UserGroup
      source_attribute_on_join_resource :group_id
      destination_attribute_on_join_resource :user_id
    end

    has_many :permissions, Warui.Accounts.GroupPermission do
      description "List of permission assigned to this group"
      destination_attribute :group_id
    end
  end
end
