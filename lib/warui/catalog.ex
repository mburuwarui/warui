defmodule Warui.Catalog do
  use Ash.Domain, extensions: [AshGraphql.Domain, AshJsonApi.Domain]

  resources do
    resource Warui.Catalog.Notebook
  end
end
