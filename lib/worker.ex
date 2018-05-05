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
    |> handle_errors(team_id)
  end

  defp handle_errors({:ok, _} = response, _team), do: response

  defp handle_errors({:error, "Slack API returned an error `invalid_auth" <> _}, team),
    do: reset(team)

  defp handle_errors({:error, "Slack API returned an error `account_inactive" <> _}, team),
    do: reset(team)

  defp handle_errors(response, team) do
    IO.puts("UNEXPECTED response from start_link for #{team}")
    IO.inspect(response)
    :ignore
  end

  defp reset(team) do
    IO.puts("Resetting the version_id for #{team} to 0")
    Worker.Database.reset_version(team)
    :ignore
  end
end
