defmodule Worker.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {DynamicSupervisor, name: Worker.Supervisor, strategy: :one_for_one},
      {TeamMonitor, []}
    ]
    Supervisor.start_link(children, [strategy: :one_for_one])
  end
end
