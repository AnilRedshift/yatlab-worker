defmodule TeamMonitor do
  use GenServer

  # 1 minute in milliseconds
  @delay 60000
  @no_teams MapSet.new()
  def start_link(_) do
    GenServer.start_link(__MODULE__, @no_teams)
  end

  def init(state) do
    poll(100)
    {:ok, state}
  end

  def handle_info(:update, state), do: update(state)

  defp get_teams() do
    Worker.Database.get_teams()
    |> Enum.into(MapSet.new())
  end

  defp poll(delay \\ @delay) do
    Process.send_after(self(), :update, delay)
  end

  defp start(teams) when teams == @no_teams, do: IO.puts("No new teams")

  defp start(teams) do
    teams
    |> Enum.each(fn team ->
      IO.puts("Starting worker for #{team}")
      {:ok, _} = DynamicSupervisor.start_child(Worker.Supervisor, {Worker, team})
    end)
  end

  defp update(state) do
    teams = get_teams()

    teams
    |> MapSet.difference(state)
    |> start

    poll()
    {:noreply, teams}
  end
end
