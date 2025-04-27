defmodule WaruiWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [Warui.Accounts],
    open_api: "/open_api"
end
