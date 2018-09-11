# osu! API

[![Build Status](https://travis-ci.com/christopher-dG/osu-api-ex.svg?branch=master)](https://travis-ci.com/christopher-dG/osu-api-ex)
[![Hex.pm](https://img.shields.io/hexpm/v/osu_api.svg)](https://hex.pm/packages/osu_api)

**A wrapper around the osu! API.**

## Installation

In your `mix.exs`:

```elixir
defp deps do
  [{:osu_api, "~> 0.1"}]
end
```

## Usage


```elixir
iex> OsuAPI.get_user("cookiezi", event_days: 5)
{:ok, %{user_id: 124493, username: "Cookiezi", ...}}
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

## Configuration

To access the osu! API, you need to provide an API key.
You can pass the `k` parameter around if you want,
but otherwise you can configure its value in `config.exs`:

    config :osu_api, api_key: "<your key here>"

You can also set the `OSU_API_KEY` environment variable.
