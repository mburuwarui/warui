defmodule AuthCase do
  require Ash.Query
  alias Warui.Treasury.Helpers.TypeCache
  alias Warui.Treasury.Helpers.Seeder

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

  def create_user(name) when is_binary(name) and name != "" do
    # Create a user and the person organization automatically.
    # The person organization will be the tenant for the query
    count = System.unique_integer([:monotonic, :positive])

    organization_domain = "#{String.downcase(name)}_organization_#{count}"

    user_params = %{
      email: "#{String.downcase(name)}.tester_#{count}@example.com",
      current_organization: organization_domain
    }

    user = Ash.Seed.seed!(Warui.Accounts.User, user_params)

    # Create a new team for the user
    organization_attrs = %{
      name: "#{String.capitalize(name)} Organization #{count}",
      domain: organization_domain,
      owner_user_id: user.id
    }

    organization = Ash.Seed.seed!(Warui.Accounts.Organization, organization_attrs)

    Ash.Seed.seed!(Warui.Accounts.UserOrganization, %{
      user_id: user.id,
      organization_id: organization.id
    })

    # Seed treasury types
    Seeder.seed_treasury_types(user)
    TypeCache.init_caches(user)

    # Return created user
    user
  end

  def create_user(_), do: {:error, "Name is required"}
end
