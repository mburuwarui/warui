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
      {Phoenix.PubSub, name: Warui.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Warui.Finch},
      # Start a worker by calling: Warui.Worker.start_link(arg)
      # {Warui.Worker, arg},
      # Start to serve requests, typically the last entry
      WaruiWeb.Endpoint,
      {AshAuthentication.Supervisor, [otp_app: :warui]}
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
