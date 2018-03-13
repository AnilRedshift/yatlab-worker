defmodule SlackBotTest do
  import Mox
  alias Worker.Database.Credentials
  use ExUnit.Case

  @bot_id "bot_user_123"

  test "handle_event ignores messages sent from the bot" do
    message = %{
      type: "message",
      text: "You clicked the button",
      channel: "my_channel",
      ts: "my_timestamp",
      user: %{
        id: @bot_id
      },
    }
    assert {:ok, state} = Worker.SlackBot.handle_event(message, slack, state)
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
    }
  end
end
