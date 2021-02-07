# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :diff,
  ecto_repos: [Diff.Repo],
  tmp_dir: "/tmp/diff",
  registry: Diff.Registry

config :diff, :bucket,
  implementation: Diff.Storage.Local,
  name: "diff"

config :diff, Oban,
  repo: Diff.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [source_fetcher: 5]

# Configures the endpoint
config :diff, DiffWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YVExBComiY3FGntGjpp8rSY9vAjqtg889rM0rwW98lHiKl2eii7BnwinPRimv/uv",
  render_errors: [view: DiffWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Diff.PubSub,
  live_view: [signing_salt: "xCOKwsLb"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
