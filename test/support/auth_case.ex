defmodule AuthCase do
  require Ash.Query

  def login(conn, user) do
    case AshAuthentication.Jwt.token_for_user(user, %{}, domain: Warui.Accounts) do
      {:ok, token, _claims} ->
        conn
        |> Phoenix.ConnTest.init_test_session(%{})
        |> Plug.Conn.put_session(:user_token, token)

      {:error, reason} ->
        raise "Failed to generate token: #{inspect(reason)}"
    end
  end

  def create_user() do
    # Create a user and the person organization automatically.
    # The person organization will be the tenant for the query
    count = System.unique_integer([:monotonic, :positive])

    organization_domain = "organization_#{count}"

    user_params = %{
      email: "john.tester_#{count}@example.com",
      current_organization: organization_domain
    }

    user = Ash.Seed.seed!(Warui.Accounts.User, user_params)

    # Create a new team for the user
    organization_attrs = %{
      name: "Organization #{count}",
      domain: organization_domain,
      owner_user_id: user.id
    }

    organization = Ash.Seed.seed!(Warui.Accounts.Organization, organization_attrs)

    Ash.Seed.seed!(Warui.Accounts.UserOrganization, %{
      user_id: user.id,
      organization_id: organization.id
    })

    # Return created team
    user
  end
end
