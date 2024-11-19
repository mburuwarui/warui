defmodule Warui.Repo.Migrations.AddPasswordAuthenticationAndAddPasswordAuth do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:users) do
      add :confirmed_at, :utc_datetime_usec
      add :hashed_password, :text, null: false
    end
  end

  def down do
    alter table(:users) do
      remove :hashed_password
      remove :confirmed_at
    end
  end
end
