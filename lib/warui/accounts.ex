defmodule Warui.Accounts do
  use Ash.Domain

  resources do
    resource Warui.Accounts.Token
    resource Warui.Accounts.User
  end
end
