use Mix.Config

config :worker,
  prod: true,
  db_host: "${DB_PORT_5432_TCP_ADDR}",
  db_user: "postgres",
  db_password: "${DB_ENV_POSTGRES_PASSWORD}",
  db_path: "postgres"
