use Mix.Config

config :worker,
  database_api: Worker.DatabaseApi.MockClient,
  slack_web_chat_api: Worker.SlackWebApi.Chat.MockClient,
  slack_web_im_api: Worker.SlackWebApi.Im.MockClient,
  slack_web_reactions_api: Worker.SlackWebApi.Reactions.MockClient
