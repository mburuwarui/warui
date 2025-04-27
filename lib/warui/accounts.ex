defmodule Warui.Accounts do
  use Ash.Domain, otp_app: :warui, extensions: [AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource Warui.Accounts.Token
    resource Warui.Accounts.User
  end
end
