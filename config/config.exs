# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

# Configures the endpoint
config :expert_advice, ExpertAdviceWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "SEjLh4z9iXzqUEw07ihox9jNfsQetOEQttZ/jHGRFXekSjI4Eezngz2KJg28imr4",
  render_errors: [view: ExpertAdviceWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: ExpertAdvice.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :expert_advice, ecto_repos: [ExpertAdviceStorage.Repo]

config :expert_advice, ExpertAdviceStorage.Repo,
  migration_timestamps: [type: :naive_datetime_usec],
  database: System.get_env("POSTGRES_DB"),
  username: System.get_env("POSTGRES_USERNAME"),
  password: System.get_env("POSTGRES_PASSWORD"),
  hostname: System.get_env("POSTGRES_HOSTNAME"),
  port: System.get_env("POSTGRES_PORT"),
  pool_size: 10

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
