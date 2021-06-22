# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :crun_subs,
  ecto_repos: [CrunSubs.Repo],
  generators: [binary_id: true]

# Configures the endpoint
config :crun_subs, CrunSubsWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: System.get_env("SECRET_KEY_BASE"),
  render_errors: [view: CrunSubsWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: CrunSubs.PubSub,
  live_view: [signing_salt: System.get_env("SIGNING_SALT")]

# Floki config
config :floki, :html_parser, Floki.HTMLParser.FastHtml

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
