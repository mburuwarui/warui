defmodule Warui.Accounts.GroupPermission do
  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource],
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "group_permissions"
    repo Warui.Repo
  end

  json_api do
    type "group_permission"

    primary_key do
      keys [:group_id, :resource, :action]
    end
  end

  graphql do
    type :group_permission
  end

  actions do
    default_accept [:resource, :action, :group_id]
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

    attribute :action, :string do
      allow_nil? false
    end

    attribute :resource, :string do
      allow_nil? false
    end

    timestamps()
  end

  relationships do
    belongs_to :group, Warui.Accounts.Group do
      description "Relationshp with a group inside a tenant"
      source_attribute :group_id
      allow_nil? false
    end
  end

  identities do
    identity :unique_group_permission, [:group_id, :resource, :action]
  end
end
