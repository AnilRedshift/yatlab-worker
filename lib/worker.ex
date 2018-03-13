defmodule Worker do
  def hello do
    team_id = Application.get_env(:worker, :team_id)
    {:ok, results} = Database.call(team_id)
    Slack.Bot.start_link(SlackBot, results, results.credentials.bot_access_token)
  end
end
