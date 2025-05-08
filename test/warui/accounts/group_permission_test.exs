defmodule Warui.Accounts.GroupPermissionTest do
  use WaruiWeb.ConnCase, async: false
  require Ash.Query

  describe "Access Group Permission Tests" do
    test "Permission can be added to a group" do
      # Prepare data
      perm_attr = %{action: "read", resource: "category"}
      permission = Ash.create!(Warui.Accounts.Permission, perm_attr)

      user = create_user("Joe")
      group_attrs = %{name: "Accountants", description: "Can manage billing in the system"}
      group = Ash.create!(Warui.Accounts.Group, group_attrs, actor: user)

      # Attempt to link group to permission
      group_perm_attrs = %{group_id: group.id, permission_id: permission.id}

      group_perm =
        Ash.create!(
          Warui.Accounts.GroupPermission,
          group_perm_attrs,
          actor: user,
          load: [:group, :permission]
        )

      # Confirm that the association happened and in the right tenant
      assert user.current_organization == Ash.Resource.get_metadata(group_perm, :tenant)
      assert group_perm.permission.id == permission.id
      assert group_perm.group.id == group.id
    end
  end
end
