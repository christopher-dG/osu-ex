# osu!ex

[![Build Status](https://travis-ci.com/christopher-dG/osu-ex.svg?branch=master)](https://travis-ci.com/christopher-dG/osu-ex)
[![Hex.pm](https://img.shields.io/hexpm/v/osu_ex.svg)](https://hex.pm/packages/osu_ex)

**[osu!](https://osu.ppy.sh) tools for Elixir.**

osu!ex provides the following (so far):

* API client (`OsuEx.API`)
* .db and .osr file parsers (`OsuEx.Parser`)

## Installation

In your `mix.exs`:

```elixir
defp deps do
  [{:osu_ex, "~> 0.1"}]
end
```

## `OsuEx.API`

**A wrapper around the osu! API.**

### Usage

```elixir
iex> {:ok, u} = OsuEx.API.get_user("cookiezi"); u
%{
  accuracy: 98.85315704345703,
  count100: 368145,
  count300: 9087788,
  count50: 32334,
  count_rank_a: 505,
  count_rank_s: 99,
  count_rank_sh: 568,
  count_rank_ss: 22,
  count_rank_ssh: 70,
  country: "KR",
  events: [],
  level: 101.69,
  playcount: 22667,
  pp_country_rank: 2,
  pp_rank: 3,
  pp_raw: 13849.5,
  ranked_score: 34166564378,
  total_score: 195920565377,
  total_seconds_played: 1832614,
  user_id: 124493,
  username: "Cookiezi"
}
```

The `get_*` function names mirror the API itself as do the parameter names,
which can be passed as a trailing keyword list.

The returned data is mostly identical to the osu! API documentation,
except for the following:

* The return value of functions which return at most one result
  (`get_user/2` for example) is a map instead of a list containing one map.
  If no result is found, then the value is `nil`, instead of an empty list.
* Numbers, booleans, dates, and lists are parsed to their native types,
  and enum values are converted to their symbolic values as atoms.

To parse enum values like `approved: 3` into more human-readable atoms,
or encode/decode mods, see the `OsuAPI.Utils` module.

### Configuration

To access the osu! API, you need to provide an API key.
You can pass the `k` parameter around if you want,
but otherwise you can configure its value in `config.exs`:

    config :osu_ex, api_key: "<your key here>"

You can also set the `OSU_API_KEY` environment variable.

## `OsuEx.Parser`

**A parser for .osr replay files.**

### Usage

Parse a replay by passing the file path or contents to `OsuEx.Parser.osr/1`.

```elixir
iex> {:ok, r} = OsuEx.Parser.osr("test/data/cookiezi-fd4d.osr"); r
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
  perfect?: true,
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

{:ok, ^r} = "test/data/cookiezi-fd4d.osr" |> File.read!() |> OsuEx.Parser.osr()
```

More details on the file format can be found [here](https://osu.ppy.sh/help/wiki/osu!_File_Formats/Osr_(file_format)).

Note that this module does not decode the LZMA-encoded replay data.
