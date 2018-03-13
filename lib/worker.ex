defmodule Worker do
  use GenServer

  def start_link(team_id) do
    IO.inspect("start link called with #{team_id}")
    GenServer.start_link(__MODULE__, team_id)
  end

  def init(team_id) do
    {:ok, results} = Worker.Database.call(team_id)
    Slack.Bot.start_link(Worker.SlackBot, results, results.credentials.bot_access_token)
  end
end
