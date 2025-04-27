defmodule Warui.Accounts.UserTest do
  use WaruiWeb.ConnCase, async: false
  require Ash.Query

  describe "User tests:" do
    test "User creation - creates personal organization automatically" do
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

      # Confirm that the new user has a personal team created for them automatically
      refute Warui.Accounts.User
             |> Ash.Query.filter(id == ^user.id)
             |> Ash.Query.filter(email == ^user_params.email)
             |> Ash.Query.filter(is_nil(current_organization))
             |> Ash.exists?(authorize?: false)
    end
  end
end
