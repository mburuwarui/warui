defmodule Warui.Accounts.AccessGroupLiveTest do
  use WaruiWeb.ConnCase, async: false

  describe "User Access Group Test:" do
    test "All resource actions can be listed for permissions" do
      assert Warui.permissions()
             |> is_list()
    end
  end
end
