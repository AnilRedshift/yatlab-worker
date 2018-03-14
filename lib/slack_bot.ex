defmodule Worker.SlackBot do
  use Slack
  alias Worker.Database.Acronym

  @slack_web_chat_api Application.get_env(:worker, :slack_web_chat_api)
  @slack_web_im_api Application.get_env(:worker, :slack_web_im_api)
  @slack_web_reactions_api Application.get_env(:worker, :slack_web_reactions_api)
  @slack_web_channels_api Application.get_env(:worker, :slack_web_channels_api)
  @slack_web_groups_api Application.get_env(:worker, :slack_web_groups_api)
  @emoji "question"

  def handle_connect(slack, state) do
    IO.puts("Slack bot connected to team #{state.team_id}")
    {:ok, state}
  end

  def handle_event(%{user: %{id: user_id}}, %{me: %{id: bot_id}}, state) when user_id == bot_id,
    do: {:ok, state}

  # Ignore all specialized messages
  def handle_event(%{type: "message", subtype: _}, _, state), do: {:ok, state}

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

  # All DM's start with D, ignore reactions added to direct messages
  def handle_event(%{type: "reaction_added", item: %{channel: "D" <> _}}, _, state),
    do: {:ok, state}

  def handle_event(%{type: "reaction_added", item: %{type: "message"}} = message, _, state) do
    state = Worker.Database.update(state)
    text = get_text(message, state)
    acronyms = Worker.MessageParser.parse(text, state.acronyms)
    send_acronyms(acronyms, message.user, state)
    {:ok, state}
  end

  def handle_event(_, _, state), do: {:ok, state}
  def handle_info(_, _, state), do: {:ok, state}

  defp bot_token(state), do: state.credentials.bot_access_token
  defp web_token(state), do: state.credentials.access_token

  defp get_text(%{item: %{ts: ts, channel: "G" <> _ = group}}, state) do
    get_text(@slack_web_groups_api.replies(group, ts, %{token: web_token(state)}))
  end

  defp get_text(%{item: %{ts: ts, channel: channel}}, state) do
    get_text(@slack_web_channels_api.replies(channel, ts, %{token: web_token(state)}))
  end

  defp get_text(%{"messages" => []}), do: ""
  defp get_text(%{"messages" => [%{"text" => text}]}), do: text

  defp send_acronyms([], _, _), do: nil

  defp send_acronyms(
         [%Acronym{name: name, means: "", description: description} | acronyms],
         user,
         state
       ) do
    send_acronym("#{name}: #{description}", user, state)
    send_acronyms(acronyms, user, state)
  end

  defp send_acronyms(
         [%Acronym{name: name, means: means, description: ""} | acronyms],
         user,
         state
       ) do
    send_acronym("#{name} stands for #{means}.", user, state)
    send_acronyms(acronyms, user, state)
  end

  defp send_acronyms(
         [%Acronym{name: name, means: means, description: description} | acronyms],
         user,
         state
       ) do
    send_acronym("#{name} stands for #{means}. Description: #{description}", user, state)
    send_acronyms(acronyms, user, state)
  end

  defp send_acronym(text, user, state) do
    %{"channel" => %{"id" => channel_id}} =
      @slack_web_im_api.open(user, %{token: bot_token(state)})

    @slack_web_chat_api.post_message(channel_id, text, %{token: bot_token(state), as_user: false})
  end
end
