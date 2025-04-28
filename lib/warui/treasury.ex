defmodule Warui.Treasury do
  use Ash.Domain, otp_app: :warui, extensions: [AshGraphql.Domain, AshJsonApi.Domain]

  resources do
    resource Warui.Treasury.Ledger
    resource Warui.Treasury.UserLedger
    resource Warui.Treasury.Account
  end
end
