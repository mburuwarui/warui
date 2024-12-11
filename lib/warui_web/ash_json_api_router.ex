defmodule WaruiWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [Module.concat(["Warui.Catalog"])],
    open_api: "/open_api"
end
