defmodule TeamMonitor do
  use GenServer

  # 1 minute in milliseconds
  @delay 60000
  def start_link(_) do
    GenServer.start_link(__MODULE__, MapSet.new())
  end

  def init(state) do
    poll(0)
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

  defp start([]), do: IO.puts("No new teams")

  defp start(teams) do
    teams
    |> Enum.each(fn team ->
      {:ok, _} = DynamicSupervisor.start_child(Worker.Supervisor, {Worker, team})
    end)
  end

  defp update(state) do
    teams = get_teams()
    IO.puts("Polling for new teams")

    teams
    |> MapSet.difference(state)
    |> start

    poll()
    {:noreply, teams}
  end
end
