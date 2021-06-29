# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :valenca, Valenca.Repo,
  database: "valenca_repo",
  username: "user",
  password: "pass",
  hostname: "localhost"

config :valenca,
  ecto_repos: [Valenca.Repo]

# Configures the endpoint
config :valenca, ValencaWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "nSAvWV7myvr61lYjE1XaSQYg7EGumV0S2rz6QVjGrGg+i1ef2Kibj67KL5BAeL6T",
  render_errors: [view: ValencaWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Valenca.PubSub,
  live_view: [signing_salt: "MYd23FXv"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
