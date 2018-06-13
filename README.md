# OsuAPI

[![Build Status](https://travis-ci.com/christopher-dG/osu-api-ex.svg?branch=master)](https://travis-ci.com/christopher-dG/osu-api-ex)

**A wrapper around the [osu! API](https://github.com/ppy/osu-api/wiki).**

## Making Requests

```elixir
OsuAPI.get(:user, u: "Cookiezi")
```

This module uses `HTTPoison` under the hood, so knowing its basics
will explain most usage patterns. To make a request, use `get/2` or `get!/2`.

Rather than passing the full URL, only the part after the `"get_"` prefix is
used. So instead of `"https://osu.ppy.sh/api/get_user"`, pass only `"user"`
(`:user` works too).

Request parameters can be passed as a keyword list after the URL.

The return value is just an `HTTPoison.Response`, so the data is in `body`.
Response data is mostly identical to the osu! API documentation, except that
integers, floats, and dates are parsed to their native types, and enums
are converted to their values as atoms.

## API Key

To access the osu! API, you need to provide an API key.
You can pass the `k` parameter to `get` or `get!`if you want,
but otherwise you can configure its value in `config.exs`:

```elixir
config :osu_api, api_key: "<your key here>"
```

## Advanced Requests

As previously mentioned, this module is built on top of `HTTPoison`, which
means that you can take advantage of extra features such as async requests.

To make a direct HTTP request, use `get/3` or `get!/3`, which work in
exactly the same way as their respective `HTTPoison` functions.
