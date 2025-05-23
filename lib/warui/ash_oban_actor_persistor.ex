defmodule Warui.AshObanActorPersister do
  alias Warui.Treasury.Helpers.TypeCache
  use AshOban.ActorPersister

  def store(%Warui.Accounts.User{id: id}), do: %{"type" => "user", "id" => id}

  def lookup(%{"type" => "user", "id" => id}), do: TypeCache.user(id)

  # This allows you to set a default actor
  # in cases where no actor was present
  # when scheduling.
  def lookup(nil), do: {:ok, nil}
end
