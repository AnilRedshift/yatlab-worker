defmodule Worker do
  use GenServer

  def start_link(_) do
    GenServer.start_link(__MODULE__, :ok)
  end

  def init(:ok) do
    team_id = Application.get_env(:worker, :team_id)
    {:ok, results} = Worker.Database.call(team_id)
    Slack.Bot.start_link(Worker.SlackBot, results, results.credentials.bot_access_token)
  end
end
