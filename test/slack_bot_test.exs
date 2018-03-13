defmodule SlackBotTest do
  import Mox
  alias Worker.Database.{Credentials, Acronym}
  use ExUnit.Case

  @bot_id "bot_user_123"
  @user_id "real_user_345"
  @team_id "team_id_999"
  @dm_channel "D789"
  @channel "C123"
  @group "G456"
  @reaction "question"
  @ts "thread_id_222"

  setup :verify_on_exit!

  test "ignores messages sent from the bot" do
    m = message(%{user: %{ id: @bot_id }})
    assert {:ok, _} = Worker.SlackBot.handle_event(m, slack(), state())
  end

  test "ignores messages sent from another bot" do
    m = message(%{subtype: "bot_message"})
    assert {:ok, %{}} = Worker.SlackBot.handle_event(m, slack(), state())
  end

  test "adds a checkbox if one acronym is in the text" do
    Worker.SlackWebApi.Reactions.MockClient
    |> expect(:add, fn @reaction, %{} ->
      {:ok}
    end)
    assert {:ok, %{}} = Worker.SlackBot.handle_event(message(), slack(), state())
  end

  test "does not add the reaction when there are no acronyms in the text" do
    m = message(%{text: "There are no acronyms here"})
    assert {:ok, %{}} = Worker.SlackBot.handle_event(m, slack(), state())
  end

  test "sends a DM when the question emoji is clicked in a channel" do
    setup_channels_replies_mock()
    setup_im_open_mock()
    setup_chat_post_message_mock()
    assert {:ok, %{}} = Worker.SlackBot.handle_event(reaction_message(), slack(), state())
  end

  test "sends a DM when the question emoji is clicked in a group message" do
    setup_groups_replies_mock()
    setup_im_open_mock()
    setup_chat_post_message_mock()
    m = reaction_message(
      %{
        item: %{
          type: "message",
          ts: @ts,
          channel: @group,
        }
      }
    )
    assert {:ok, %{}} = Worker.SlackBot.handle_event(m, slack(), state())
  end

  defp setup_channels_replies_mock(text \\ "I need this by EOD.") do
    Worker.SlackWebApi.Channels.MockClient
    |> expect(:replies, fn (@channel, @ts, _) ->
      %{
        "messages" => [
          %{
            "text" => text,
          },
        ],
      }
    end)
  end

  defp setup_groups_replies_mock(text \\ "I need this by EOD.") do
    Worker.SlackWebApi.Groups.MockClient
    |> expect(:replies, fn (@group, @ts, _) ->
      %{
        "messages" => [
          %{
            "text" => text,
          },
        ],
      }
    end)
  end

  defp setup_im_open_mock(user_id \\ @user_id) do
    Worker.SlackWebApi.Im.MockClient
    |> expect(:open, fn ^user_id, _ ->
      %{
        "channel" => %{
          "id" => @dm_channel,
        },
      }
    end)
  end

  defp setup_chat_post_message_mock() do
    Worker.SlackWebApi.Chat.MockClient
    |> expect(:post_message, fn(@dm_channel, _, _) -> {:ok} end)
  end

  defp reaction_message(%{} = options \\ %{}) do
    defaults = %{
      type: "reaction_added",
      reaction: @reaction,
      item: %{
        type: "message",
        ts: @ts,
        channel: @channel,
      },
      user: @user_id,
    }
    Map.merge(defaults, options)
  end

  defp message(%{} = options \\ %{}) do
    defaults = %{
      type: "message",
      text: "I need this by EOD.",
      channel: "my_channel",
      ts: @ts,
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
