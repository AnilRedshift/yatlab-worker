defmodule SlackMessager do
  use Slack

  def handle_connect(slack, state) do
    IO.puts "Connected as #{slack.me.name}"
    {:ok, state}
  end

  def handle_event(%{type: "message"} = message, slack, state) do
    case message.text do
      "Matt" ->
        token = state.credentials.bot_access_token
        Slack.Web.Reactions.add("question", %{token: token, channel: message.channel, timestamp: message.ts})
      _ -> {:ok}
    end
    {:ok, state}
  end
  def handle_event(_, _, state), do: {:ok, state}

  def handle_info({:message, text, channel}, slack, state) do
    IO.puts "Sending your message, captain!"

    send_message(text, channel, slack)

    {:ok, state}
  end
  def handle_info(_, _, state), do: {:ok, state}
end

#slack.me.id
