defmodule Warui.Accounts do
  use Ash.Domain,
    otp_app: :warui,
    extensions: [AshGraphql.Domain, AshJsonApi.Domain, AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource Warui.Accounts.Token
    resource Warui.Accounts.User
    resource Warui.Accounts.Organization
    resource Warui.Accounts.UserOrganization
    resource Warui.Accounts.Group
    resource Warui.Accounts.GroupPermission
    resource Warui.Accounts.UserGroup
    resource Warui.Accounts.ApiKey
  end
end
