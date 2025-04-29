defmodule Warui.MixProject do
  use Mix.Project

  def project do
    [
      app: :warui,
      version: "0.1.0",
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      consolidate_protocols: Mix.env() != :dev,
      aliases: aliases(),
      deps: deps(),
      listeners: [Phoenix.CodeReloader]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Warui.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:tigerbeetlex, github: "rbino/tigerbeetlex"},
      {:mpesa_elixir, "~> 0.1.1"},
      {:nebulex, "~> 2.6"},
      {:shards, "~> 1.1"},
      {:decorator, "~> 1.4"},
      {:ex_money_sql, "~> 1.0"},
      {:ash_money, "~> 0.2"},
      {:mix_test_watch, "~> 1.2", only: [:dev, :test], runtime: false},
      {:bcrypt_elixir, "~> 3.0"},
      {:picosat_elixir, "~> 0.2"},
      {:absinthe_phoenix, "~> 2.0"},
      {:sourceror, "~> 1.8", only: [:dev, :test]},
      {:oban, "~> 2.0"},
      {:open_api_spex, "~> 3.0"},
      {:ash_cloak, "~> 0.1"},
      {:cloak, "~> 1.0"},
      {:ash_paper_trail, "~> 0.5"},
      {:mishka_chelekom, "~> 0.0", only: [:dev]},
      {:live_debugger, "~> 0.1", only: [:dev]},
      {:ash_archival, "~> 1.0"},
      {:ash_state_machine, "~> 0.2"},
      {:oban_web, "~> 2.0"},
      {:ash_oban, "~> 0.4"},
      {:ash_admin, "~> 0.13"},
      {:ash_authentication_phoenix, "~> 2.0"},
      {:ash_authentication, "~> 4.0"},
      {:ash_postgres, "~> 2.0"},
      {:ash_json_api, "~> 1.0"},
      {:ash_graphql, "~> 1.0"},
      {:ash_phoenix, "~> 2.0"},
      {:ash, "~> 3.0"},
      {:igniter, "~> 0.5", only: [:dev, :test]},
      {:phoenix, "~> 1.8.0-rc.0", override: true},
      {:phoenix_ecto, "~> 4.5"},
      {:ecto_sql, "~> 3.10"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.1"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0"},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.9", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.3", runtime: Mix.env() == :dev},
      {:heroicons,
       github: "tailwindlabs/heroicons",
       tag: "v2.1.1",
       sparse: "optimized",
       app: false,
       compile: false,
       depth: 1},
      {:swoosh, "~> 1.16"},
      {:req, "~> 0.5"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ash.setup", "assets.setup", "assets.build", "run priv/repo/seeds.exs"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ash.setup --quiet", "test"],
      "ash.setup.all": ["cmd mix ash.setup && MIX_ENV=test mix ash.setup"],
      "ash.migrate.tenant": [
        "cmd mix ash.migrate --migrations-path priv/repo/tenant_migrations && MIX_ENV=test mix ash.migrate --migrations-path priv/repo/tenant_migrations"
      ],
      "setup.all": ["ash.setup.all", "ash.migrate.tenant"],
      seed: [
        "run priv/repo/seeds.exs"
      ],
      "drop.all": [
        "cmd mix ash_postgres.drop && MIX_ENV=test mix ash_postgres.drop"
      ],
      "assets.setup": ["tailwind.install --if-missing", "esbuild.install --if-missing"],
      "assets.build": ["tailwind warui", "esbuild warui"],
      "assets.deploy": [
        "tailwind warui --minify",
        "esbuild warui --minify",
        "phx.digest"
      ]
    ]
  end
end
