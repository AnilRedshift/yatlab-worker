defmodule Worker do
  def hello do
    {:ok, results} = Worker.Database.call("T028NREAQ")
    Slack.Bot.start_link(SlackMessager, results, results.credentials.bot_access_token)
  end
end
