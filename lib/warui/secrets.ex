defmodule Warui.Secrets do
  use AshAuthentication.Secret

  def secret_for([:authentication, :tokens, :signing_secret], Warui.Accounts.User, _opts) do
    Application.fetch_env(:warui, :token_signing_secret)
  end
end
