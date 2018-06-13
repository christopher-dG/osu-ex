defmodule OsuAPI do
  @moduledoc """
  **A wrapper around the osu! API.**

  response bodies, with the exception that integers, floats, and dates are
  parsed into their native types.

  # Making Requests

      OsuAPI.get("user", u: "Cookiezi")

  This module uses `HTTPoison` under the hood, so knowing its basics
  will explain most usage patterns. To make a request, use `get/2` or `get!/2`

  Rather than passing the full URL, only the part after the "get" prefix is
  used. So instead of `"https://osu.ppy.sh/api/get_user"`, pass only `"user"`.

  Request parameters can be passed as a keyword list after the URL.

  The return value is just an `HTTPoison.Response`, so the data is in `body`.
  Response data is identical to the osu! API documentation, except that
  integers, floats, and dates are parsed to their native types.

  # API Key

  To access the osu! API, you need to provide an API key.
  Yoy can pass the `k` parameter to `get` or `get!`if you want,
  but otherwise you can configure its value in `config.exs`:

      config :osu_api, api_key: "<your key here>"

  # Advanced Requests

  As previously mentioned, this module is built on top of `HTTPoison`, which
  means that you can take advantage of extra features such as async requests.

  To make a direct HTTP request, use `get/3` or `get!/3`, which work in
  exactly the same way as the respective `HTTPoison` functions.
  """

  @spec get(binary, keyword) :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get(endpoint, params \\ []), do: OsuAPI.HTTP.get("#{endpoint}", [], params: Map.new(params))

  @spec get(binary, HTTPoison.headers(), keyword) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get(endpoint, headers, options), do: OsuAPI.HTTP.get("#{endpoint}", headers, options)

  @spec get!(binary, keyword) :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get!(endpoint, params \\ []),
    do: OsuAPI.HTTP.get!("#{endpoint}", [], params: Map.new(params))

  @spec get!(binary, HTTPoison.headers(), keyword) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get!(endpoint, headers, options), do: OsuAPI.HTTP.get!("#{endpoint}", headers, options)
end
