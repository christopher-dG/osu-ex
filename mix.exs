defmodule OsuAPI.MixProject do
  use Mix.Project

  def project do
    [
      app: :osu_api,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      name: "osu! API",
      description: "A wrapper around the osu! API.",
      source_url: "https://github.com/christopher-dG/osu-api-ex",
      homepage_url: "https://github.com/christopher-dG/osu-api-ex"
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.2"},
      {:jason, "~> 1.1"},
      {:ex_doc, "~> 0.18", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/christopher-dG/osu-api-ex",
        "osu! API Documentation" => "https://github.com/ppy/osu-api/wiki"
      }
    ]
  end
end
