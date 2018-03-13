use Mix.Config

config :worker,
  database_url: System.get_env("DATABASE_URL"),
  database_api: Worker.DatabaseApi.Postgres,
  team_id: System.get_env("TEAM_ID")

import_config "#{Mix.env}.exs"
