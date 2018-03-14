defmodule Worker.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, name: Worker.Supervisor, strategy: :one_for_one},
      {TeamMonitor, []},
      postgres()
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp postgres() do
    options = [
      hostname: Application.get_env(:worker, :db_host),
      username: Application.get_env(:worker, :db_user),
      password: Application.get_env(:worker, :db_password),
      database: Application.get_env(:worker, :db_path)
    ]

    %{
      id: App.Database,
      start: {Postgrex, :start_link, [options]}
    }
  end
end
