defmodule Worker.SlackBot do
  use Slack
  alias Worker.Database.Acronym

  @slack_web_chat_api Application.get_env(:worker, :slack_web_chat_api)
  @slack_web_reactions_api Application.get_env(:worker, :slack_web_reactions_api)
  @slack_web_channels_api Application.get_env(:worker, :slack_web_channels_api)
  @slack_web_groups_api Application.get_env(:worker, :slack_web_groups_api)
  @slack_web_im_api Application.get_env(:worker, :slack_web_im_api)
  @emoji "question"
  @help_text "Hi! To use yatlab, simply invite me to one of your channels. When I see any of the acronyms listed at <https://yatlab.terminal.space/>. I will add a :question: reaction. If any user clicks the :question:, I'll respond. Give it a shot!"

  def handle_connect(_, state) do
    IO.puts("Slack bot connected to team #{state.team_id}")
    {:ok, state}
  end

  def handle_event(%{user: %{id: user_id}}, %{me: %{id: bot_id}}, state) when user_id == bot_id,
    do: {:ok, state}

  # Ignore all specialized messages
  def handle_event(%{type: "message", subtype: _}, _, state), do: {:ok, state}

  def handle_event(%{type: "message", text: "help", channel: "D" <> _ = channel}, _, state) do
    %{"message" => %{"ts" => response_ts}} =
      @slack_web_chat_api.post_message(channel, @help_text, %{
        token: bot_token(state),
        as_user: false
      })

    @slack_web_reactions_api.add(@emoji, %{
      token: bot_token(state),
      channel: channel,
      timestamp: response_ts
    })

    {:ok, state}
  end

  def handle_event(%{type: "message"} = message, _, state) do
    state = Worker.Database.update(state)

    if match?([_ | _], Worker.MessageParser.parse(message.text, state.acronyms)) do
      @slack_web_reactions_api.add(@emoji, %{
        token: bot_token(state),
        channel: message.channel,
        timestamp: message.ts
      })
    end

    {:ok, state}
  end

  def handle_event(%{type: "reaction_added", reaction: reaction}, _, state)
      when reaction != @emoji,
      do: {:ok, state}

  def handle_event(%{type: "reaction_added", item: %{type: "message"}} = message, _, state) do
    state = Worker.Database.update(state)
    text = get_text(message, state)
    handle_reaction(message, text, state)
    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}

  def handle_reaction(%{user: user, item: %{channel: "D" <> _ = channel}}, @help_text, state) do
    response = "TEST stands for ... well this is just a test! Try it with other acronyms"

    @slack_web_chat_api.post_ephemeral(channel, response, user, %{
      token: bot_token(state),
      as_user: false
    })
  end

  def handle_reaction(message, text, state) do
    acronyms = Worker.MessageParser.parse(text, state.acronyms)
    send_acronyms(acronyms, message, state)
  end

  def handle_info(_, _, state), do: {:ok, state}

  defp bot_token(state), do: state.credentials.bot_access_token
  defp web_token(state), do: state.credentials.access_token

  defp get_text(%{"messages" => []}), do: ""
  defp get_text(%{"messages" => [%{"text" => text} | _]}), do: text

  defp get_text(%{item: %{ts: ts, channel: channel}}, state) do
    params = %{token: web_token(state)}

    replies =
      case channel do
        "D" <> _ -> @slack_web_im_api.replies(channel, ts, params)
        "G" <> _ -> @slack_web_groups_api.replies(channel, ts, params)
        _ -> @slack_web_channels_api.replies(channel, ts, params)
      end

    get_text(replies)
  end

  defp send_acronyms([], _, _), do: nil

  defp send_acronyms(
         [%Acronym{name: name, means: "", description: description} | acronyms],
         message,
         state
       ) do
    send_acronym("#{name}: #{description}", message, state)
    send_acronyms(acronyms, message, state)
  end

  defp send_acronyms(
         [%Acronym{name: name, means: means, description: ""} | acronyms],
         message,
         state
       ) do
    send_acronym("#{name} stands for #{means}.", message, state)
    send_acronyms(acronyms, message, state)
  end

  defp send_acronyms(
         [%Acronym{name: name, means: means, description: description} | acronyms],
         message,
         state
       ) do
    send_acronym("#{name} stands for #{means}. Description: #{description}", message, state)
    send_acronyms(acronyms, message, state)
  end

  defp send_acronym(text, %{user: user, item: %{channel: channel}}, state) do
    @slack_web_chat_api.post_ephemeral(channel, text, user, %{
      token: bot_token(state),
      as_user: false
    })
  end
end
