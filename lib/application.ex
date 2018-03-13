defmodule Worker.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Worker, []},
    ]

    opts = [strategy: :one_for_one, name: Worker.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
