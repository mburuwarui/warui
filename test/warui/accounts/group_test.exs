defmodule Warui.Accounts.GroupTest do
  use WaruiWeb.ConnCase, async: false
  require Ash.Query

  test "User can add a group" do
    # Try to create a group
    user = create_user("Jimmy")
    new_group = %{name: "Accountant", description: "Handles billing"}
    {:ok, _} = Ash.create(Warui.Accounts.Group, new_group, actor: user)

    # Check if the group was created
    exists? =
      Warui.Accounts.Group
      |> Ash.Query.filter(name == ^new_group.name)
      |> Ash.Query.filter(description == ^new_group.description)
      |> Ash.exists?(actor: user)

    assert exists?
  end
end
