defmodule Warui.Accounts.UserTest do
  use WaruiWeb.ConnCase, async: false
  require Ash.Query

  describe "User tests:" do
    test "User creation - creates personal organization automatically with password" do
      # Create a new user
      user_params = %{
        email: "john.tester@example.com",
        password: "12345678",
        password_confirmation: "12345678"
      }

      user =
        Ash.create!(
          Warui.Accounts.User,
          user_params,
          action: :register_with_password,
          authorize?: false
        )

      # Confirm that the new user has a personal organization created for them automatically
      refute Warui.Accounts.User
             |> Ash.Query.filter(id == ^user.id)
             |> Ash.Query.filter(email == ^user_params.email)
             |> Ash.Query.filter(is_nil(current_organization))
             |> Ash.exists?(authorize?: false)
    end

    test "User creation - creates personal organization automatically with magic_link" do
      # Setup
      email = "john.tester@example.com"
      resource = Warui.Accounts.User

      # Get the strategy
      strategy = AshAuthentication.Info.strategy_for_action!(resource, :request_magic_link)

      # Directly generate a token using the same function as in the action
      {:ok, token} =
        AshAuthentication.Strategy.MagicLink.request_token_for_identity(
          strategy,
          email,
          [],
          %{}
        )

      # Use the token to create/sign in the user
      user =
        Ash.create!(
          resource,
          %{token: token},
          action: :sign_in_with_magic_link,
          authorize?: false
        )

      # Confirm that the new user has a personal organization created for them automatically
      refute Warui.Accounts.User
             |> Ash.Query.filter(id == ^user.id)
             |> Ash.Query.filter(email == ^email)
             |> Ash.Query.filter(is_nil(current_organization))
             |> Ash.exists?(authorize?: false)
    end
  end
end
