defmodule Worker.SlackWebApi do
  defmodule Chat do
    @callback post_message(channel :: String.t(), text :: String.t(), optional_params :: Map.t()) :: Map.t()
  end

  defmodule Im do
    @callback open(user :: String.t(), optional_params :: Map.t()) :: Map.t()
  end

  defmodule Reactions do
    @callback add(name :: String.t(), optional_params :: Map.t()) :: Map.t()
  end
end

defmodule Worker.SlackWebApi.Impl do
  defmodule Chat do
    @behavior Worker.SlackWebApi.Chat
    def post_message(channel, text, optional_params), do: Slack.Web.Chat.post_message(channel, text, optional_params)
  end

  defmodule Im do
    @behavior Worker.SlackWebApi.Im
    def open(user, optional_params), do: Slack.Web.Im.open(user, optional_params)
  end

  defmodule Reactions do
    @behavior Worker.SlackWebApi.Reactions
    def add(name, optional_params), do: Slack.Web.Reactions.add(name, optional_params)
  end
end
