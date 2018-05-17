defmodule SlackBotTest do
  import Mox
  alias Worker.Database.{Credentials, Acronym, Result}
  use ExUnit.Case

  @bot_id "bot_user_123"
  @user_id "real_user_345"
  @team_id "team_id_999"
  @channel "C123"
  @group "G456"
  @reaction "question"
  @ts "thread_id_222"

  setup :verify_on_exit!

  test "ignores messages sent from the bot" do
    m = message(%{user: %{id: @bot_id}})
    assert {:ok, _} = Worker.SlackBot.handle_event(m, slack(), state())
  end

  test "ignores messages sent from another bot" do
    m = message(%{subtype: "bot_message"})
    assert {:ok, %{}} = Worker.SlackBot.handle_event(m, slack(), state())
  end

  test "adds a checkbox if one acronym is in the text" do
    setup_reactions_add_mock()
    setup_logging_mock()
    assert {:ok, %{}} = Worker.SlackBot.handle_event(message(), slack(), state())
  end

  test "adds a checkbox if the acronym is lowercased" do
    setup_reactions_add_mock()
    setup_logging_mock()
    m = message(%{text: "The phrase eod is lowercased."})
    assert {:ok, %{}} = Worker.SlackBot.handle_event(m, slack(), state())
  end

  test "ignores matches within URL's" do
    m = message(%{text: "The phrase http://eod.com is in a url"})
    assert {:ok, %{}} = Worker.SlackBot.handle_event(m, slack(), state())
  end

  test "does not add the reaction when there are no acronyms in the text" do
    m = message(%{text: "There are no acronyms here"})
    assert {:ok, %{}} = Worker.SlackBot.handle_event(m, slack(), state())
  end

  test "sends a DM when the question emoji is clicked in a channel" do
    setup_channels_replies_mock()
    setup_chat_post_message_mock()
    assert {:ok, %{}} = Worker.SlackBot.handle_event(reaction_message(), slack(), state())
  end

  test "sends a DM when the question emoji is clicked in a group message" do
    setup_groups_replies_mock()
    setup_chat_post_message_mock(@group)

    m =
      reaction_message(%{
        item: %{
          type: "message",
          ts: @ts,
          channel: @group
        }
      })

    assert {:ok, %{}} = Worker.SlackBot.handle_event(m, slack(), state())
  end

  test "Sends a DM when there are multiple replies to the thread" do
    setup_channels_replies_mock(["I need this by EOD.", "This message has many replies"])
    setup_chat_post_message_mock()
    assert {:ok, %{}} = Worker.SlackBot.handle_event(reaction_message(), slack(), state())
  end

  defp setup_channels_replies_mock(replies \\ ["I need this by EOD."]) do
    Worker.SlackWebApi.Channels.MockClient
    |> expect(:replies, fn @channel, @ts, _ ->
      %{
        "messages" => Enum.map(replies, fn reply -> %{"text" => reply} end)
      }
    end)
  end

  defp setup_groups_replies_mock(text \\ "I need this by EOD.") do
    Worker.SlackWebApi.Groups.MockClient
    |> expect(:replies, fn @group, @ts, _ ->
      %{
        "messages" => [
          %{
            "text" => text
          }
        ]
      }
    end)
  end

  defp setup_chat_post_message_mock(channel \\ @channel) do
    Worker.SlackWebApi.Chat.MockClient
    |> expect(:post_ephemeral, fn channel, _, @user_id, _ -> {:ok} end)
  end

  defp setup_reactions_add_mock() do
    Worker.SlackWebApi.Reactions.MockClient
    |> expect(:add, fn @reaction, %{} ->
      {:ok}
    end)
  end

  defp setup_logging_mock() do
    Worker.DatabaseApi.MockClient
    |> expect(:set_user_typed_acronym, fn acronym_id: _, user_id: _ ->
      {
        :ok,
        %Postgrex.Result{
          columns: nil,
          rows: nil
        }
      }
    end)
  end

  defp reaction_message(%{} = options \\ %{}) do
    defaults = %{
      type: "reaction_added",
      reaction: @reaction,
      item: %{
        type: "message",
        ts: @ts,
        channel: @channel
      },
      user: @user_id
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
      }
    }

    Map.merge(defaults, options)
  end

  defp slack do
    %{
      me: %{
        id: @bot_id
      }
    }
  end

  defp state do
    %Result{
      time: Time.utc_now(),
      team_id: @team_id,
      credentials: %Credentials{},
      acronyms: [
        %Acronym{
          id: 0,
          name: "EOD",
          means: "End of day",
          description: "",
          team_id: @team_id,
          added_by: "Ada"
        },
        %Acronym{
          id: 0,
          name: "THROW",
          means: "Train human really obey wishes",
          description: "Dogs want you to throw the ball",
          team_id: @team_id,
          added_by: "Ada"
        }
      ]
    }
  end
end
