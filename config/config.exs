use Mix.Config

config :worker,
  db_host: "${DB_HOST}",
  db_user: "${DB_USER}",
  db_password: "${DB_PASS}",
  db_path: "${DB_PATH}",
  database_api: Worker.DatabaseApi.Postgres,
  slack_web_channels_api: Worker.SlackWebApi.Impl.Channels,
  slack_web_chat_api: Worker.SlackWebApi.Impl.Chat,
  slack_web_groups_api: Worker.SlackWebApi.Groups.Channels,
  slack_web_im_api: Worker.SlackWebApi.Impl.Im,
  slack_web_reactions_api: Worker.SlackWebApi.Impl.Reactions,
  team_id: "${TEAM_ID}"

import_config "#{Mix.env}.exs"
