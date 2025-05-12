defmodule Warui.Accounts.AccessGroupLiveTest do
  use WaruiWeb.ConnCase, async: false

  describe "User Access Group Test:" do
    test "All resource actions can be listed for permissions" do
      assert Warui.permissions()
             |> is_list()
    end

    test "Group form renders successfully" do
      user = create_user()

      assigns = %{
        actor: user,
        group_id: nil,
        id: Ash.UUIDv7.generate()
      }

      html = render_component(WaruiWeb.Accounts.Groups.GroupForm, assigns)

      # Confirm that all necessary fields are there
      assert html =~ "access-group-modal-button"
      assert html =~ "form[name]"
      assert html =~ "form[description]"
      assert html =~ gettext("Submit")
    end

    test "Existing group renders successfully with the component" do
      user = create_user()
      group = get_group(user)

      assigns = %{
        actor: user,
        group_id: group.id,
        id: Ash.UUIDv7.generate()
      }

      html = render_component(WaruiWeb.Accounts.Groups.GroupForm, assigns)

      # Confirm that all necessary fields are there
      assert html =~ "access-group-modal-button"
      assert html =~ "form[name]"
      assert html =~ "form[description]"
      assert html =~ gettext("Submit")

      # Confirm that group data is visible in the form
      assert html =~ group.name
      assert html =~ group.description
    end
  end
end
