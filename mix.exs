defmodule Xray.MixProject do
  use Mix.Project

  def project do
    [
      app: :xray,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.json": :test
      ]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Xray.Application, []},
      extra_applications: [:honeybadger, :logger, :runtime_tools, :iex, :os_mon]
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
      {:phoenix, "~> 1.6.0-rc.0", override: true},
      {:phoenix_ecto, "~> 4.1"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:floki, ">= 0.27.0", only: :test},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_view, "~> 0.16.0"},
      {:phoenix_live_dashboard, "~> 0.5"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:hackney, "~> 1.17"},
      {:httpoison, "~> 1.8"},
      {:oban, "~> 2.4"},
      {:credo, "~> 1.5", only: [:dev, :test]},
      {:hammox, "~> 0.5", only: :test},
      {:excoveralls, "~> 0.13.4", only: :test},
      {:ex_machina, "~> 2.6", only: :test},
      {:faker, "~> 0.16.0", only: :test},
      {:sobelow, "~> 0.11.0", only: [:dev, :test]},
      {:quantum, "~> 3.3"},
      {:jaxon, "~> 2.0"},
      {:cachex, "~> 3.3"},
      {:ex_aws, "~> 2.1"},
      {:ex_aws_s3, "~> 2.1"},
      {:sweet_xml, "~> 0.6.6"},
      {:honeybadger, "~> 0.16.0"},
      {:surface, "~> 0.5.0"},
      {:git_diff, "~> 0.6.3"},
      {:ecto_psql_extras, "~> 0.6.5"}
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
      setup: ["deps.get", "ecto.setup", "cmd npm install --prefix assets"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"]
    ]
  end
end
