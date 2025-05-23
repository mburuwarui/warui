defmodule Warui.CashFlow do
  use Ash.Domain,
    otp_app: :warui,
    extensions: [AshGraphql.Domain, AshJsonApi.Domain, AshAdmin.Domain]

  admin do
    show? true
  end

  resources do
    resource Warui.CashFlow.Budget
  end
end
