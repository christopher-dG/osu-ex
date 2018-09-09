# osu! Replay Parser

[![Build Status](https://travis-ci.com/christopher-dG/osu-replay-parser-ex.svg?branch=master)](https://travis-ci.com/christopher-dG/osu-replay-parser-ex)
[![Hex.pm](https://img.shields.io/hexpm/v/osu_replay_parser.svg)](https://hex.pm/packages/osu_replay_parser)

A parser for [osu!](https://osu.ppy.sh) replays (.osr files) written in Elixir.

## Usage

Parse a replay by passing the file path:

```elixir
iex> OsuReplayParser.parse!("test/data/cookiezi-fd4d.osr")
%{
  beatmap_md5: "da8aae79c8f3306b5d65ec951874a7fb",
  combo: 2385,
  life_bar: "",
  mode: 0,
  mods: 24,
  n100: 5,
  n300: 1978,
  n50: 0,
  ngeki: 247,
  nkatu: 4,
  nmiss: 0,
  perfect: 1,
  player: "Cookiezi",
  replay_data: <<93, 0, 0, 32, 0, 100, 53, 7, 0, 0, 0, 0, 0, 0, 24, 31, 2, 67,
    81, 3, 180, 0, 85, 87, 216, 83, 171, 4, 141, 104, 12, 141, 37, 13, 190, 92,
    ...>>,
  replay_id: 2177560145,
  replay_md5: "f0225807e33a0fb2fff5a303ef31134a",
  score: 132408001,
  timestamp: 635873755112646784,
  version: 20151228
}
```

Or by passing the file contents directly:

```elixir
iex> "test/data/cookiezi-fd4d.osr" |> File.read!() |> OsuReplayParser.parse!()
# The same result.
```

More details on the file format can be found [here](https://osu.ppy.sh/help/wiki/osu!_File_Formats/Osr_(file_format)).

Note that this library does not decode the LZMA-encoded replay data.
