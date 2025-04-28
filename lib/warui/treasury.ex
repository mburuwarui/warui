defmodule Warui.Treasury do
  use Ash.Domain, otp_app: :warui, extensions: [AshGraphql.Domain, AshJsonApi.Domain]

  resources do
    resource Warui.Treasury.Ledger
    resource Warui.Treasury.UserLedger
    resource Warui.Treasury.Account
    resource Warui.Treasury.Transfer
    resource Warui.Treasury.TransferType
    resource Warui.Treasury.AccountType
    resource Warui.Treasury.Currency
    resource Warui.Treasury.Asset
    resource Warui.Treasury.AssetType
  end
end
