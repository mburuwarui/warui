defmodule Warui.Accounts.Organization do
  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.Accounts,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  @doc """
  Tell Ash to use the domain as the tenant database prefix when using PostgreSQL as the database; otherwise, use the ID.
  """
  defimpl Ash.ToTenant do
    def to_tenant(resource, %{:domain => domain, :id => id}) do
      if Ash.Resource.Info.data_layer(resource) == AshPostgres.DataLayer &&
           Ash.Resource.Info.multitenancy_strategy(resource) == :context do
        domain
      else
        id
      end
    end
  end

  postgres do
    table "organizations"
    repo Warui.Repo

    manage_tenant do
      template ["", :domain]
      create? true
      update? false
    end
  end

  json_api do
    type "organization"
  end

  graphql do
    type :organization
  end

  actions do
    default_accept [:name, :domain, :description, :owner_user_id]
    defaults [:read]

    create :create do
      # Default create action
      primary? true
      change Warui.Accounts.Team.Changes.AssociateUserToTeam
      change Warui.Accounts.Team.Changes.SetOwnerCurrentTeam
    end
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
    belongs_to :owner, Warui.Accounts.User do
      source_attribute :owner_user_id
    end

    many_to_many :users, Warui.Accounts.User do
      through Warui.Accounts.UserOrganization
      source_attribute_on_join_resource :organization_id
      destination_attribute_on_join_resource :user_id
    end
  end
end
