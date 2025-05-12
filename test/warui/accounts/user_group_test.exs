defmodule Warui.Accounts.UserGroupTest do
  use WaruiWeb.ConnCase, async: false
  require Ash.Query

  describe "User Access Group Tests" do
    test "Group can be added to a user" do
      # Prepare data
      user = create_user()
      group_attrs = %{name: "Accountants", description: "Can manage billing in the system"}
      group = Ash.create!(Warui.Accounts.Group, group_attrs, actor: user)

      # Attempt to link group to permission
      user_group_attrs = %{group_id: group.id, user_id: user.id}

      user_group =
        Ash.create!(
          Warui.Accounts.UserGroup,
          user_group_attrs,
          actor: user,
          load: [:group, :user],
          # Set off authorize so we can auto-load user relationshp
          authorize?: false
        )

      # Confirm that the association happened and in the right tenant
      assert user.current_organization == Ash.Resource.get_metadata(user_group, :tenant)
      assert user_group.user.id == user.id
      assert user_group.group.id == group.id
    end
  end
end
