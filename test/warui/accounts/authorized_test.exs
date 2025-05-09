defmodule Warui.Accounts.AuthorizedTest do
  use WaruiWeb.ConnCase, async: false

  describe "Authorized Check" do
    test "organization owner is always authorized" do
      owner = create_user("Jimmy")

      assert Ash.can?({Warui.Treasury.Ledger, :create}, owner)
      assert Ash.can?({Warui.Treasury.Ledger, :read}, owner)
      assert Ash.can?({Warui.Treasury.Ledger, :update}, owner)
      assert Ash.can?({Warui.Treasury.Ledger, :destroy}, owner)
    end

    test "Nil actors are not authorized" do
      owner = nil

      refute Ash.can?({Warui.Treasury.Ledger, :create}, owner)
      refute Ash.can?({Warui.Treasury.Ledger, :read}, owner)
      refute Ash.can?({Warui.Treasury.Ledger, :update}, owner)
      refute Ash.can?({Warui.Treasury.Ledger, :destroy}, owner)
    end

    test "Non organization owner are allowed if they have permission" do
      owner = create_user("Jared")

      user =
        Ash.Seed.seed!(Warui.Accounts.User, %{
          email: "new_user@example.com",
          current_organization: owner.current_organization
        })

      tenant = user.current_organization

      # Add user to the organization
      organization = Ash.read_first!(Warui.Accounts.Organization)
      user_organization_attrs = %{user_id: user.id, organization_id: organization.id}

      _user_organization =
        Ash.Seed.seed!(Warui.Accounts.UserOrganization, user_organization_attrs)

      # Add permissions
      permission =
        Ash.Seed.seed!(Warui.Accounts.Permission, %{
          action: :read,
          resource: Warui.Treasury.Ledger
        })

      # Add Access group
      group =
        Ash.Seed.seed!(
          Warui.Accounts.Group,
          %{name: "Accountant", description: "Finance accountant"},
          tenant: tenant,
          authorize?: false
        )

      # Add group permission
      Ash.Seed.seed!(
        Warui.Accounts.GroupPermission,
        %{group_id: group.id, permission_id: permission.id},
        tenant: tenant,
        authorize?: false
      )

      # Add user to the group
      Ash.Seed.seed!(
        Warui.Accounts.UserGroup,
        %{user_id: user.id, group_id: group.id},
        tenant: tenant,
        authorize?: false
      )

      # # Confirm that this user is not authorized to create but authorized to read
      assert Ash.can?({Warui.Treasury.Ledger, :read}, user)
      refute Ash.can?({Warui.Treasury.Ledger, :create}, user)
      refute Ash.can?({Warui.Treasury.Ledger, :update}, user)
      refute Ash.can?({Warui.Treasury.Ledger, :destroy}, user)
    end
  end
end
