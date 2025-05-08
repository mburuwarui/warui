defmodule Warui.Accounts.PermissionTest do
  use WaruiWeb.ConnCase, async: false
  require Ash.Query

  test "User can create a permission" do
    # Try to create a permission
    new_permission = %{action: "read", resource: "ledger"}
    {:ok, _} = Ash.create(Warui.Accounts.Permission, new_permission)

    # Check if the permission was created
    exists? =
      Warui.Accounts.Permission
      |> Ash.Query.filter(action == "read" and resource == "ledger")
      |> Ash.exists?()

    assert exists?
  end
end
