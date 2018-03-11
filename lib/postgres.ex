defmodule Postgres do
  def start do
    uri = System.get_env("DATABASE_URL") |> URI.parse
    [username, password] = String.split(uri.userinfo, ":")
    Postgrex.Connection.start_link \
      hostname: uri.host,
      username: username,
      password: password,
      database: uri.path |> String.lstrip(?/)
  end
end
