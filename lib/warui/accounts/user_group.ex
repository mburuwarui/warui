defmodule Warui.Accounts.UserGroup do
  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource],
    notifiers: Ash.Notifier.PubSub

  postgres do
    table "user_groups"
    repo Warui.Repo
  end

  json_api do
    type "user_group"
  end

  graphql do
    type :user_group
  end

  actions do
    default_accept [:user_id, :group_id]
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

    timestamps()
  end

  relationships do
    belongs_to :user, Warui.Accounts.User do
      description "Permission for the user access group"
      source_attribute :user_id
      allow_nil? false
    end

    belongs_to :group, Warui.Accounts.Group do
      description "Relationshp with a group inside a tenant"
      source_attribute :group_id
      allow_nil? false
    end
  end

  identities do
    identity :unique_user_group, [:user_id, :group_id]
  end
end
