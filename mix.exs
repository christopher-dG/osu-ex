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
      source_url: "https://github.com/christopher-dG/osu-api-ex"
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.1"},
      {:jason, "~> 1.1"},
      {:ex_doc, "~> 0.18", only: :dev, runtime: false}
    ]
  end
end
