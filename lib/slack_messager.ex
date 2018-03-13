defmodule SlackMessager do
  use Slack

  @emoji "question"

  def handle_connect(slack, state) do
    IO.puts "#{slack.me.name} connected!"
    {:ok, state}
  end

  def handle_event(%{user: %{id: user_id}}, %{me: %{id: bot_id}}, state) when user_id == bot_id, do: {:ok, state}
  def handle_event(%{type: "message", subtype: "bot_message"},_, state), do: {:ok, state}
  def handle_event(%{type: "message"} = message, _, state) do
    case message.text do
      "You clicked the button" ->
        Slack.Web.Reactions.add(@emoji, %{token: token(state), channel: message.channel, timestamp: message.ts})
      _ -> {:ok}
    end
    {:ok, state}
  end

  def handle_event(%{type: "reaction_added", reaction: reaction}, _, state) when reaction != @emoji, do: {:ok, state}
  # All DM's start with D, ignore reactions added to direct messages
  def handle_event(%{type: "reaction_added", item: %{channel: "D" <> _}}, _, state), do: {:ok, state}
  def handle_event(%{type: "reaction_added", item: %{type: "message"}} = message, _, state) do
    %{"channel" => %{"id" => channel_id}} = Slack.Web.Im.open(message.user, %{token: token(state)})
    Slack.Web.Chat.post_message(channel_id, "You clicked the button", %{token: token(state), as_user: false})
    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}
  def handle_info(_, _, state), do: {:ok, state}

  defp token(state), do: state.credentials.bot_access_token
end