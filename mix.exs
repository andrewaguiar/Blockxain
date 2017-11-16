defmodule Blockxain.Mixfile do
  use Mix.Project

  def project do
    [
      app: :blockxain,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      test_coverage: [tool: Coverex.Task],
      deps: deps()
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
    [{:rsa_ex, "~> 0.1"},
     {:coverex, "~> 1.4.10", only: :test},
     {:credo, "~> 0.8", only: [:dev, :test], runtime: false}]
  end
end
