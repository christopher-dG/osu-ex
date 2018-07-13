defmodule OsuAPI.MixProject do
  use Mix.Project

  def project do
    [
      app: :osu_api,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "osu! API",
      source_url: "https://github.com/christopher-dG/osu-api-ex",
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.1"},
      {:jason, "~> 1.1"},
      {:ex_doc, "~> 0.18", only: :dev, runtime: false},
      {:excoveralls, "~> 0.9", only: :test}
    ]
  end
end
