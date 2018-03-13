defmodule Worker.Database do
  defmodule Credentials do
    defstruct \
    access_token: "",
    bot_access_token: "",
    bot_user_id: ""
  end

  defmodule Result do
    defstruct \
      team_id: nil,
      time: nil,
      name: "",
      acronyms: [],
      credentials: %Credentials{}
  end

  defmodule Acronym do
    defstruct \
    id: nil,
    name: "",
    means: "",
    description: "",
    team_id: nil,
    added_by: nil
  end

  @database_api Application.get_env(:worker, :database_api)
  @cache_time_seconds 120

  def update(%Result{team_id: team_id, time: time} = result) do
    current = Time.utc_now()
    elapsed_seconds = Time.diff(current, time)
    case (elapsed_seconds) do
      x when x in 0..@cache_time_seconds -> result
      _ ->
        IO.puts("Updating the cache for #{team_id}")
        call(team_id)
    end
  end

  def call(team_id) do
    with \
      {:ok, acronym_data} <- @database_api.get_acronyms(team_id),
      {:ok, team_data} <- @database_api.get_team(team_id),
      {:ok, acronyms} <- parse_acronyms(acronym_data),
      {:ok, name, credentials} <- parse_team(team_data)
    do
      result = %Result{
        team_id: team_id,
        time: Time.utc_now(),
        acronyms: acronyms,
        name: name,
        credentials: credentials,
      }
      {:ok, result}
    else
      {:error, %Postgrex.Error{} = error} ->
        {:error, %{code: "db_error", message: error.message}}
      {:error, error} -> {:error, error}
      _ -> {:error, %{code: "unknown"}}
    end
  end

  defp parse_acronyms(result) do
    {:ok, Enum.map(parse_result(result), &struct(Acronym, &1))}
  end

  defp parse_team(result) do
    case parse_result(result) do
      [team]-> {:ok, team.name, struct(Credentials, team)}
      _ -> {:error, %{code: "invalid_team"}}
    end
  end

  defp parse_result(%Postgrex.Result{columns: columns, rows: rows}) do
    columns = Enum.map(columns, &String.to_atom/1)
    Enum.map(rows, fn row ->
      Enum.zip(columns, row) |> Enum.into(%{})
    end)
  end
end
