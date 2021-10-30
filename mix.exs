defmodule PgRun.MixProject do
  use Mix.Project

  def project do
    [
      app: :pg_run,
      version: "0.1.0",
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.6", only: :test},
      {:postgrex, ">= 0.0.0", only: :test},
      {:docker_compose, "~> 0.2.0"}
    ]
  end

  defp elixirc_paths(:test) do
    ["lib", "test/repo", "test/support"]
  end

  defp elixirc_paths(_) do
    ["lib"]
  end
end
