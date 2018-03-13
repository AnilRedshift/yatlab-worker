defmodule Worker.MixProject do
  use Mix.Project

  def project do
    [
      app: :worker,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Worker.Application, []}
    ]
  end

  defp aliases do
    [
      test: "test --no-start",
    ]
  end
  defp deps do
    [
      {:distillery, "~> 1.5"},
      {:poison, "~> 3.1"},
      {:postgrex, "~> 0.13.5"},
      {:slack, git: "https://github.com/AnilRedshift/Elixir-Slack.git"},
      {:mox, "~> 0.3", only: :test},
    ]
  end
end
