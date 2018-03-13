defmodule Worker.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    teams = Worker.Database.get_teams()
    children = Enum.map(teams, fn team -> {Worker, team} end)
    opts = [strategy: :one_for_one, name: Worker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
