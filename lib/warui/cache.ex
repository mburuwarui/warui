defmodule Warui.Cache do
  use Nebulex.Cache,
    otp_app: :warui,
    adapter: Nebulex.Adapters.Local
end
