defmodule StatsTest do
  require Postgrex
  alias Worker.Stats
  alias Worker.Database.Acronym
  import Mox
  use ExUnit.Case

  @user_id "U123"
  @acronym1 %Acronym{
    added_by: "Anil Kulkarni",
    description: "he's a ham",
    id: 6,
    means: "Jordan",
    name: "HAM",
    team_id: "team1"
  }
  setup :verify_on_exit!

  test "log one acronym" do
    stub_update_acronyms([@acronym1])
    Stats.log_typed_acronyms(acronyms: [@acronym1], user_id: @user_id)
  end

  defp stub_update_acronyms([]), do: nil

  defp stub_update_acronyms([%{id: acronym_id} | acronyms]) do
    Worker.DatabaseApi.MockClient
    |> expect(:set_user_typed_acronym, fn acronym_id: ^acronym_id, user_id: @user_id ->
      {
        :ok,
        %Postgrex.Result{
          columns: nil,
          rows: nil
        }
      }
    end)

    stub_update_acronyms(acronyms)
  end
end
