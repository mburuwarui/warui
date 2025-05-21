defmodule WaruiWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [Warui.Accounts, Warui.Treasury, Warui.CashFlow],
    open_api: "/open_api"
end
