defmodule Worker.DatabaseApi do
  @callback get_acronyms(team_id :: String.t()) :: {:ok, %Postgrex.Result{}}
  @callback get_team(team_id :: String.t()) :: {:ok, %Postgrex.Result{}}
end

defmodule Worker.DatabaseApi.Postgres do
  require Postgrex
  @behaviour Worker.DatabaseApi

  def get_acronyms(team_id) do
    query = "SELECT * from acronyms WHERE team_id = $1"
    params = [team_id]
    execute(query, params)
  end

  def get_team(team_id) do
    query = "SELECT * from teams where id = $1"
    params = [team_id]
    execute(query, params)
  end

  defp execute(query, params) do
    with \
      {:ok, conn} <- start(),
      {:ok, results} <- Postgrex.query(conn, query, params)
    do
      {:ok, results}
    else
      error -> error
    end
  end

  defp start do
    uri = Application.get_env(:worker, :database_url) |> URI.parse
    [username, password] = String.split(uri.userinfo, ":")
    Postgrex.start_link \
      hostname: uri.host,
      username: username,
      password: password,
      database: uri.path |> String.lstrip(?/)
  end
end
