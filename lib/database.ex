defmodule Worker.Database do
  defmodule Credentials do
    defstruct \
    access_token: "",
    bot_access_token: "",
    bot_user_id: ""
  end

  defmodule Result do
    defstruct \
      name: "",
      acronyms: [],
      credentials: %Credentials{}
  end

  defmodule Acronym do
    defstruct \
    id: nil,
    name: nil,
    means: nil,
    description: nil,
    team_id: nil,
    added_by: nil
  end

  @database_api Application.get_env(:worker, :database_api)

  def call(team_id) do
    acronyms = parse_acronyms(@database_api.get_acronyms(team_id))
    {name, credentials} = parse_team(@database_api.get_team(team_id))
    result = %Result{
      acronyms: acronyms,
      name: name,
      credentials: credentials,
    }
    {:ok, result}
  end

  defp parse_acronyms({:ok, %Postgrex.Result{} = result}) do
    Enum.map(parse_result(result), &struct(Acronym, &1))
  end

  defp parse_acronyms(error) do
    error
  end

  defp parse_team({:ok, %Postgrex.Result{} = result}) do
    [team] = parse_result(result)
    {team.name, struct(Credentials, team)}
  end

  defp parse_result(%Postgrex.Result{columns: columns, rows: rows}) do
    columns = Enum.map(columns, &String.to_atom/1)
    Enum.map(rows, fn row ->
      Enum.zip(columns, row) |> Enum.into(%{})
    end)
  end
end
