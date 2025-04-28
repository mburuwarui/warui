defmodule Warui.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WaruiWeb.Telemetry,
      Warui.Repo,
      {DNSCluster, query: Application.get_env(:warui, :dns_cluster_query) || :ignore},
      {Oban,
       AshOban.config(
         Application.fetch_env!(:warui, :ash_domains),
         Application.fetch_env!(:warui, Oban)
       )},
      {Phoenix.PubSub, name: Warui.PubSub},
      # Start a worker by calling: Warui.Worker.start_link(arg)
      # {Warui.Worker, arg},
      # Start to serve requests, typically the last entry
      WaruiWeb.Endpoint,
      {Absinthe.Subscription, WaruiWeb.Endpoint},
      AshGraphql.Subscription.Batcher,
      {AshAuthentication.Supervisor, [otp_app: :warui]},
      Warui.Cache,
      Warui.Treasury.TypeCacheStartup,
      {TigerBeetlex.Connection,
       [
         cluster_id: <<0::128>>,
         addresses: ["3000"],
         name: :tb
       ]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Warui.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WaruiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
