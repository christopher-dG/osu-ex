# OsuAPI

[![Build Status](https://travis-ci.com/christopher-dG/osu-api-ex.svg?branch=master)](https://travis-ci.com/christopher-dG/osu-api-ex)

**A wrapper around the osu! API.**

## Installation

In your `mix.exs`:

```elixir
defp deps do
  [{:osu_api, git: "https://github.com/christopher-dG/osu-api-ex"}]
end
```

## Usage

This module uses `HTTPoison` under the hood, so knowing its basics
will explain most usage patterns.

Most users will want to make requests with the endpoint-specific functions
(`get_user/2`, `get_scores/2`, etc.), but `get/2` can also be used directly.

Additional request parameters can be passed as a trailing keyword list.
Their names mirror the osu! API documentation.

The return value is just an `HTTPoison.Response`, so the data is in `body`.
Response data is mostly identical to the osu! API documentation, except for
the following:

* The response body of functions which return at most one result (`get_user`,
  `get_beatmap`, etc.) is a single map, instead of a list containing one map.
* Numbers, booleans, and dates are parsed to their native types, and enums
  are converted to their values as atoms.
* Enums whose names end in "_id" have the suffix removed, since the atoms aren't IDs.


## Configuration

To access the osu! API, you need to provide an API key.
You can pass the `k` parameter around if you want,
but otherwise you can configure its value in `config.exs`:

config :osu_api, api_key: "<your key here>"

## Custom/Advanced Requests

As previously mentioned, this module is built on top of `HTTPoison`, which
means that you can take advantage of extra features such as async requests.

To make a direct HTTP request, use `get/3` or `get!/3`, which work almost
identically to their respective `HTTPoison` functions.

Note that response type conversions are performed for `get/3` and `get!/3`, but
all other request/response processing is skipped.
For example, `get_user("username")`'s will set the `type` parameter for you
and return just a single map in the response, while `get(:user, u: "username")`
will leave `type` unset and return a list with one map in the response.

## `type` Parameter

In `get_user_*` functions which take an optional `type` parameter, passing
"string" or "id" manually is redundant because it is generated from `user`'s type.
