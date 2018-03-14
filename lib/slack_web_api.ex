defmodule Worker.SlackWebApi do
  defmodule Channels do
    @callback replies(channel :: String.t(), thread_ts :: String.t(), optional_params :: Map.t()) ::
                Map.t()
  end

  defmodule Chat do
    @callback post_message(channel :: String.t(), text :: String.t(), optional_params :: Map.t()) ::
                Map.t()
  end

  defmodule Groups do
    @callback replies(channel :: String.t(), thread_ts :: String.t(), optional_params :: Map.t()) ::
                Map.t()
  end

  defmodule Im do
    @callback open(user :: String.t(), optional_params :: Map.t()) :: Map.t()
  end

  defmodule Reactions do
    @callback add(name :: String.t(), optional_params :: Map.t()) :: Map.t()
  end
end

defmodule Worker.SlackWebApi.Impl do
  defmodule Channels do
    @behaviour Worker.SlackWebApi.Channels
    def replies(channel, thread_ts, optional_params),
      do: Slack.Web.Channels.replies(channel, thread_ts, optional_params)
  end

  defmodule Chat do
    @behaviour Worker.SlackWebApi.Chat
    def post_message(channel, text, optional_params),
      do: Slack.Web.Chat.post_message(channel, text, optional_params)
  end

  defmodule Groups do
    @behaviour Worker.SlackWebApi.Groups
    def replies(channel, thread_ts, optional_params),
      do: Slack.Web.Groups.replies(channel, thread_ts, optional_params)
  end

  defmodule Im do
    @behaviour Worker.SlackWebApi.Im
    def open(user, optional_params), do: Slack.Web.Im.open(user, optional_params)
  end

  defmodule Reactions do
    @behaviour Worker.SlackWebApi.Reactions
    def add(name, optional_params), do: Slack.Web.Reactions.add(name, optional_params)
  end
end
