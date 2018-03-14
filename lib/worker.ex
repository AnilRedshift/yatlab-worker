defmodule Worker do
  use GenServer

  def child_spec(team_id) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [team_id]},
      type: :worker
    }
  end

  def start_link(team_id) do
    GenServer.start_link(__MODULE__, team_id)
  end

  def init(team_id) do
    IO.puts("Worker running for #{team_id}")
    {:ok, results} = Worker.Database.call(team_id)
    Slack.Bot.start_link(Worker.SlackBot, results, results.credentials.bot_access_token)
  end
end
