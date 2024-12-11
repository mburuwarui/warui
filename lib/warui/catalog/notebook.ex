defmodule Warui.Catalog.Notebook do
  use Ash.Resource,
    otp_app: :warui,
    domain: Warui.Catalog,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshGraphql.Resource, AshJsonApi.Resource]

  json_api do
    type "notebook"
  end

  graphql do
    type :notebook
  end

  postgres do
    table "notebooks"
    repo Warui.Repo
  end

  actions do
    defaults [
      :read,
      :destroy,
      create: [:title, :body, :picture],
      update: [:title, :body, :picture]
    ]
  end

  attributes do
    uuid_primary_key :id

    attribute :title, :string do
      allow_nil? false
      public? true
    end

    attribute :body, :string do
      allow_nil? false
      public? true
    end

    attribute :picture, :string do
      allow_nil? false
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
