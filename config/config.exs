use Mix.Config

config :worker,
  database_url: System.get_env("DATABASE_URL"),
  database_api: Worker.DatabaseApi.Postgres,
  slack_web_chat_api: Worker.SlackWebApi.Impl.Chat,
  slack_web_im_api: Worker.SlackWebApi.Impl.Im,
  slack_web_reactions_api: Worker.SlackWebApi.Reactions,
  team_id: System.get_env("TEAM_ID")

import_config "#{Mix.env}.exs"
