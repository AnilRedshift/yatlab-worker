defmodule DatabaseTest do
  import Mox
  use ExUnit.Case
  alias Worker.Database.{Acronym, Result, Credentials}
  doctest Worker.Database

  setup :verify_on_exit!

  @team_id "team1"

  defp stub_get_acronyms do
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
  end

  defp expected_acronyms do
    [
      %Worker.Database.Acronym{
        added_by: "Anil Kulkarni",
        description: "the dumbest acronym",
        id: 2,
        means: "three letter acronym",
        name: "TLA",
        team_id: "team1"
      },
      %Worker.Database.Acronym{
        added_by: "Anil Kulkarni",
        description: "he's a ham",
        id: 6,
        means: "Jordan",
        name: "HAM",
        team_id: "team1"
      },
    ]
  end

  defp stub_get_team do
    Worker.DatabaseApi.MockClient
    |> expect(:get_team, fn @team_id ->
      {:ok,
      %Postgrex.Result{
        columns: ["id", "access_token", "bot_user_id", "bot_access_token", "name"],
        command: :select,
        connection_id: 61431,
        num_rows: 1,
        rows: [
          [@team_id,
          "xoxp-access-token",
          "UBOTUSERID",
          "xoxb-bot-token",
          "My Cool Team"]
        ]
      }}
    end)
  end

  defp expected_credentials do
    %Credentials{
      access_token: "xoxp-access-token",
      bot_user_id: "UBOTUSERID",
      bot_access_token: "xoxb-bot-token",
    }
  end

  test "returns team and acronym data on success" do
    stub_get_acronyms
    stub_get_team

    expected = %Result{
      name: "My Cool Team",
      acronyms: expected_acronyms,
      credentials: expected_credentials,
    }

    assert Worker.Database.call(@team_id) == {:ok, expected}
  end
end
