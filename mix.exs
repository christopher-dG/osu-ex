defmodule OsuEx.MixProject do
  use Mix.Project

  def project do
    [
      app: :osu_ex,
      version: "0.2.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      name: "osu!ex",
      description: "osu! tools for Elixir.",
      source_url: "https://github.com/christopher-dG/osu-ex",
      homepage_url: "https://github.com/christopher-dG/osu-ex"
    ]
  end

  defp deps do
    [
      {:httpoison, "~> 1.5"},
      {:jason, "~> 1.1"},
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/christopher-dG/osu-ex",
        "osu! API Documentation" => "https://github.com/ppy/osu-api/wiki",
        "Replay File Format Documentation" =>
          "https://osu.ppy.sh/help/wiki/osu!_File_Formats/Osr_(file_format)"
      }
    ]
  end
end
