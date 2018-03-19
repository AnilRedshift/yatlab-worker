defmodule Worker.DmHandler do
  @help_text "Hi! To use yatlab, simply invite me to one of your channels. When I see any of the acronyms listed at <https://yatlab.terminal.space/>. I will add a :question: reaction. If any user clicks the :question:, I'll respond. Give it a shot!"

  def handle_dm(%{text: "help", channel: channel}, _, state), do: help(channel, state)
  def handle_dm(message, state), do: nil

  defp help(channel, state) do
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
end
