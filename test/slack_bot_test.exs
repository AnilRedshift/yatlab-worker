defmodule SlackBotTest do
  import Mox
  alias Worker.Database.{Credentials, Acronym}
  use ExUnit.Case

  @bot_id "bot_user_123"
  @user_id "real_user_345"
  @team_id "team_id_999"

  setup :verify_on_exit!

  test "handle_event ignores messages sent from the bot" do
    m = message(%{user: %{ id: @bot_id }})
    assert {:ok, _} = Worker.SlackBot.handle_event(m, slack(), state())
  end

  test "handle_event ignores messages sent from another bot" do
    m = message(%{subtype: "bot_message"})
    assert {:ok, %{}} = Worker.SlackBot.handle_event(m, slack(), state())
  end

  test "handle_event adds a checkbox if one acronym is in the text" do
    Worker.SlackWebApi.Reactions.MockClient
    |> expect(:add, fn "question", %{} ->
      {:ok}
    end)
    assert {:ok, %{}} = Worker.SlackBot.handle_event(message(), slack(), state())
  end

  test "handle_event does not add the reaction when there are no acronyms in the text" do
    m = message(%{text: "There are no acronyms here"})
    assert {:ok, %{}} = Worker.SlackBot.handle_event(m, slack(), state())
  end

  defp message(%{} = options \\ %{}) do
    defaults = %{
      type: "message",
      text: "I need this by EOD.",
      channel: "my_channel",
      ts: "my_timestamp",
      user: %{
        id: @user_id
      },
    }
    Map.merge(defaults, options)
  end

  defp slack do
    %{
      me: %{
        id: @bot_id,
      },
    }
  end

  defp state do
    %{
      credentials: %Credentials{},
      acronyms: [
        %Acronym{
          id: 0,
          name: "EOD",
          means: "End of day",
          description: "",
          team_id: @team_id,
          added_by: "Ada",
        },
        %Acronym{
          id: 0,
          name: "THROW",
          means: "Train human really obey wishes",
          description: "Dogs want you to throw the ball",
          team_id: @team_id,
          added_by: "Ada",
        },
      ],
    }
  end
end
