defmodule DatabaseTest do
  import Mox
  use ExUnit.Case
  doctest Worker.Database

  setup :verify_on_exit!

  @team_id "team1"

  test "returns team and acronym data on success" do
    Worker.DatabaseApi.MockClient
      |> expect(:get_acronyms, fn @team_id ->
        {:ok, %Postgrex.Result{
          columns: ["id", "name", "means", "description", "team_id", "added_by"],
          rows: [
            [2, "TLA", "three letter acronym", "the dumbest acronym", @team_id,
            "Anil Kulkarni"],
            [6, "HAM", "Jordan", "he's a ham", @team_id, "Anil Kulkarni"],
          ]
        }}
      end)

      assert Worker.Database.call(@team_id) == {:ok, %Postgrex.Result{
        columns: ["id", "name", "means", "description", "team_id", "added_by"],
        rows: [
          [2, "TLA", "three letter acronym", "the dumbest acronym", @team_id,
          "Anil Kulkarni"],
          [6, "HAM", "Jordan", "he's a ham", @team_id, "Anil Kulkarni"],
        ]
      }}
  end
end
