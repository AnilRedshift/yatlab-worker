defmodule Worker.DatabaseApi do
  @callback get_acronyms(team_id :: String.t()) :: {:ok, %Postgrex.Result{}}
  @callback get_team(team_id :: String.t()) :: {:ok, %Postgrex.Result{}}
  @callback get_teams() :: {:ok, %Postgrex.Result{}}
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

  def get_teams() do
    execute("SELECT id from teams", [])
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
    Postgrex.start_link \
      hostname: Application.get_env(:worker, :db_host),
      username: Application.get_env(:worker, :db_user),
      password: Application.get_env(:worker, :db_password),
      database: Application.get_env(:worker, :db_path)
  end
end
