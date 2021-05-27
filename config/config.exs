# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :xray,
  ecto_repos: [Xray.Repo],
  tmp_dir: "/tmp/xray",
  registry: Xray.Registry,
  npm_api: Xray.Api.Npm,
  httpoison: HTTPoison

config :xray, :bucket,
  implementation: Xray.Storage.S3,
  name: "xray"

config :ex_aws,
  region: "eu-central-1",
  s3: [
    scheme: "https://",
    host: "s3.eu-central-1.wasabisys.com",
    region: "eu-central-1"
  ]

config :xray, Oban,
  repo: Xray.Repo,
  plugins: [Oban.Plugins.Pruner],
  queues: [source_fetcher: 5, package_list_fetcher: 1, diff: 1]

# Configures the endpoint
config :xray, XrayWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "YVExBComiY3FGntGjpp8rSY9vAjqtg889rM0rwW98lHiKl2eii7BnwinPRimv/uv",
  render_errors: [view: XrayWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Xray.PubSub,
  live_view: [signing_salt: "xCOKwsLb"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :xray, Xray.Scheduler,
  jobs: [
    {"@daily", {Xray.Scheduler, :update_package_lists, []}}
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
