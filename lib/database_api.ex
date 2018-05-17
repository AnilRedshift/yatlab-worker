defmodule Worker.DatabaseApi do
  @callback get_acronyms(team_id :: String.t()) :: {:ok, %Postgrex.Result{}}
  @callback get_team(team_id :: String.t()) :: {:ok, %Postgrex.Result{}}
  @callback get_teams() :: {:ok, %Postgrex.Result{}}
  @callback set_user_typed_acronym(acronym_id: acronym_id :: integer, user_id: user_id :: String.t()) :: {:ok, %Postgrex.Result{}}
  @callback reset_version(team_id :: String.t()) :: {:ok, %Postgrex.Result{}}
end

defmodule Worker.DatabaseApi.Postgres do
  require Postgrex
  @behaviour Worker.DatabaseApi
  @version 2

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
    execute("SELECT id from teams where version = $1", [@version])
  end

  def set_user_typed_acronym(acronym_id: acronym_id, user_id: user_id) do
    query = """
    INSERT INTO acronyms_users (acronym_id,user_id,acro_user, count)
    VALUES ($1, $2, $3, 1)
    ON CONFLICT (acro_user) DO UPDATE SET count = acronyms_users.count + 1
    """
    params = [acronym_id, user_id, "#{acronym_id}#{user_id}"]
    execute(query, params)
  end

  def reset_version(team_id) do
    query = "UPDATE teams SET version = 0 WHERE id = $1"
    params = [team_id]
    execute(query, params)
  end

  defp execute(query, params), do: Postgrex.query(:app_database, query, params)
end
