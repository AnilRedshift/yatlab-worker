defmodule Worker.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      postgres(),
      {DynamicSupervisor,
       name: Worker.Supervisor, strategy: :one_for_one, max_restarts: 100, max_seconds: 5},
      {TeamMonitor, []}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end

  defp postgres() do
    options = [
      hostname: Application.get_env(:worker, :db_host),
      username: Application.get_env(:worker, :db_user),
      password: Application.get_env(:worker, :db_password),
      database: Application.get_env(:worker, :db_path),
      name: :app_database
    ]

    %{
      id: App.Database,
      start: {Postgrex, :start_link, [options]}
    }
  end
end
