defmodule SlackBotTest do
  import Mox
  alias Worker.Database.Credentials
  use ExUnit.Case

  @bot_id "bot_user_123"
  @user_id "real_user_345"

  test "handle_event ignores messages sent from the bot" do
    m = message(%{user: %{ id: @bot_id }})
    assert {:ok, state} = Worker.SlackBot.handle_event(m, slack, state)
  end

  test "Ignore messages sent from another bot" do
  end

  defp message(%{} = options \\ %{}) do
    defaults = %{
      type: "message",
      text: "You clicked the button",
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
    }
  end
end
