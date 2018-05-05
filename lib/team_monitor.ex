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

  defp start(teams) when teams == @no_teams do
    IO.puts("No new teams")
    teams
  end

  defp start(teams) do
    Enum.each(teams, fn team -> IO.puts("Team monitor starting #{team}") end)

    teams
    |> Enum.map(fn team ->
      {team, DynamicSupervisor.start_child(Worker.Supervisor, {Worker, team})}
    end)
    |> Enum.filter(fn {_, result} -> started?(result) end)
    |> Enum.map(fn {team, _} -> team end)
    |> MapSet.new()
  end

  defp started?({:ok, _}), do: true
  defp started?(_), do: false

  defp update(state) do
    all_teams = get_teams()

    running_teams =
      all_teams
      |> MapSet.difference(state)
      |> start
      |> MapSet.union(state)

    MapSet.difference(all_teams, running_teams)
    |> handle_failed_teams

    poll()
    {:noreply, running_teams}
  end

  defp handle_failed_teams(teams) do
    teams
    |> Enum.each(fn team ->
      IO.puts("Failed to start team #{team}")
    end)
  end
end
