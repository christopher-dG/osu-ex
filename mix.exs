defmodule OsuReplayParser.MixProject do
  use Mix.Project

  def project do
    [
      app: :osu_replay_parser,
      version: "0.1.1",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      name: "osu! Replay Parser",
      description: "A parser for osu replays (.osr files).",
      source_url: "https://github.com/christopher-dG/osu-replay-parser-ex",
      homepage_url: "https://github.com/christopher-dG/osu-replay-parser-ex"
    ]
  end

  defp deps do
    [
      {:ex_doc, "~> 0.19", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        GitHub: "https://github.com/christopher-dG/osu-replay-parser-ex",
        "File Format Documentation":
          "https://osu.ppy.sh/help/wiki/osu!_File_Formats/Osr_(file_format"
      }
    ]
  end
end
