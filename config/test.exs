use Mix.Config

config :worker,
  :database_api, Worker.DatabaseApi.MockClient
