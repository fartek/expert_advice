use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :expert_advice, ExpertAdviceWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

config :expert_advice, ExpertAdviceStorage.Repo,
  database: "expert_advice_test",
  username: "root",
  password: "root",
  hostname: "localhost",
  port: "5432",
  pool: Ecto.Adapters.SQL.Sandbox

config :pbkdf2_elixir, :rounds, 1
