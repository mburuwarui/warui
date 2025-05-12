defmodule Warui.Accounts.OrganizationTest do
  use WaruiWeb.ConnCase, async: false
  require Ash.Query

  describe "Organization tests" do
    test "User organization can be created" do
      # create_user/0 is automatically imported from ConnCase
      user = create_user()

      # Create a new team for the user
      organization_attrs = %{name: "Org 1", domain: "org_1", owner_user_id: user.id}
      {:ok, organization} = Ash.create(Warui.Accounts.Organization, organization_attrs)

      # New team should be stored successfully
      assert Warui.Accounts.Organization
             |> Ash.Query.filter(domain == ^organization.domain)
             |> Ash.Query.filter(owner_user_id == ^organization.owner_user_id)
             |> Ash.exists?()

      # New team should be set as the current team on the owner
      assert Warui.Accounts.User
             |> Ash.Query.filter(id == ^user.id)
             |> Ash.Query.filter(current_organization == ^organization.domain)
             # authorize?: false disables policy checks
             |> Ash.exists?(authorize?: false)

      # New team should be added to the teams list of the owner
      assert Warui.Accounts.User
             |> Ash.Query.filter(id == ^user.id)
             |> Ash.Query.filter(organizations.id == ^organization.id)
             |> Ash.exists?(authorize?: false)
    end
  end
end
