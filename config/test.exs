import Config

config :warui,
  tigerbeetle: [
    cluster_id: <<0::128>>,
    addresses: ["3000"]
  ]

config :warui, Oban, testing: :manual
config :warui, token_signing_secret: "+5TYcq0nc+ri+VluPmwm7kdqExTfc9HT"
config :bcrypt_elixir, log_rounds: 1

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :warui, Warui.Repo,
  username: "postgres",
  password: "postgres",
  hostname: "localhost",
  database: "warui_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :warui, WaruiWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "FgPC7xmUKusAMYYGi7osv+AmWdJvvJ2/AGxyc1jPhlm9hP78M9epeagoWyt9EgWW",
  server: false

# In test we don't send emails
config :warui, Warui.Mailer, adapter: Swoosh.Adapters.Test

# Disable swoosh api client as it is only required for production adapters
config :swoosh, :api_client, false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

# Enable helpful, but potentially expensive runtime checks
config :phoenix_live_view,
  enable_expensive_runtime_checks: true

config :ash, :disable_async?, true
config :ash, :missed_notifications, :ignore
config :bcrypt_elixir, log_rounds: 1
