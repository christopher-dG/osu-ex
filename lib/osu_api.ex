defmodule OsuAPI do
  @moduledoc """
  **A wrapper around the osu! API.**

  # Usage

  This module uses `HTTPoison` under the hood, so knowing its basics
  will explain most usage patterns.

  Most users will want to make requests with the endpoint-specific functions
  (`get_user/2`, `get_scores/2`, etc.), but `get/2` can also be used directly.

  Additional request parameters can be passed as a trailing keyword list.
  Their names mirror the osu! API documentation.

  The return value is just an `HTTPoison.Response`, so the data is in `body`.
  Response data is mostly identical to the osu! API documentation, except that
  numbers, booleans, and dates are parsed to their native types, and enums
  are converted to their values as atoms.
  Enums whose names end in "_id" have the suffix removed, since the atoms aren't IDs.

  # Configuration

  To access the osu! API, you need to provide an API key.
  You can pass the `k` parameter around if you want,
  but otherwise you can configure its value in `config.exs`:

      config :osu_api, api_key: "<your key here>"

  # Advanced Requests

  As previously mentioned, this module is built on top of `HTTPoison`, which
  means that you can take advantage of extra features such as async requests.

  To make a direct HTTP request, use `get/3` or `get!/3`, which work in
  exactly the same way as their respective `HTTPoison` functions.

  # `type` Parameter

  In `get_user_*` functions which take an optional `type` parameter, passing
  "string" or "id" manually is redundant because it is generated from `user`'s type.
  """

  defguardp is_endpoint(endpoint) when is_atom(endpoint) or is_binary(endpoint)
  defguardp is_user(user) when is_binary(user) or is_integer(user)
  @type endpoint :: atom | binary
  @type user :: integer | binary
  defp user_type(user) when is_user(user), do: if(is_binary(user), do: "string", else: "id")

  @doc """
  Sends a request to `endpoint` with the given `params`.
  `endpoint` should be the URL path without the "get_" prefix, as an atom or string.
  """
  @spec get(endpoint, keyword) :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get(endpoint, params \\ []) when is_endpoint(endpoint),
    do: OsuAPI.HTTP.get("#{endpoint}", [], params: Map.new(params))

  @doc """
  See `get/2` for documentation on `endpoint`.
  See `HTTPoison.get/3` for documentation on `headers` and `options`.
  """
  @spec get(endpoint, HTTPoison.headers(), keyword) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get(endpoint, headers, options) when is_endpoint(endpoint),
    do: OsuAPI.HTTP.get("#{endpoint}", headers, options)

  @doc "Same as `get/2`, but returns just the response and can throw exceptions."
  @spec get!(atom | binary, HTTPoison.headers(), keyword) :: HTTPoison.Response.t()
  def get!(endpoint, params \\ []) when is_endpoint(endpoint),
    do: OsuAPI.HTTP.get!("#{endpoint}", [], params: Map.new(params))

  @doc """
  See `get/2` for documentation on `endpoint`.
  See `HTTPoison.get!/3` for documentation on `headers` and `options`.
  """
  @spec get!(atom | binary, HTTPoison.headers(), keyword) :: HTTPoison.Response.t()
  def get!(endpoint, headers, options) when is_endpoint(endpoint),
    do: OsuAPI.HTTP.get!("#{endpoint}", headers, options)

  @doc "Gets beatmaps."
  @spec get_beatmap(keyword) :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_beatmaps(opts \\ []), do: get(:beatmaps, opts)

  @doc "Same as `get_beatmaps/1` but returns just the response and can throw exceptions."
  @spec get_beatmap!(keyword) :: HTTPoison.Response.t()
  def get_beatmaps!(opts \\ []), do: get!(:beatmaps, opts)

  @doc "Gets a beatmap by ID (beatmap ID, not beatmapset ID)."
  @spec get_beatmap(integer, keyword) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_beatmap(id, opts \\ []) when is_integer(id),
    do: get(:beatmaps, Keyword.put(opts, :b, id))

  @doc "Same as `get_beatmap/2` but returns just the response and can throw exceptions."
  @spec get_beatmap!(integer, keyword) :: HTTPoison.Response.t()
  def get_beatmap!(id, opts \\ []) when is_integer(id),
    do: get!(:beatmaps, Keyword.put(opts, :b, id))

  @doc "Gets a beatmapset by ID (beatmapset ID, not beatmap ID)."
  @spec get_beatmapset(integer, keyword) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_beatmapset(id, opts \\ []) when is_integer(id),
    do: get(:beatmaps, Keyword.put(opts, :s, id))

  @doc "Same as `get_beatmapset/2` but returns just the response and can throw exceptions."
  @spec get_beatmapset!(integer, keyword) :: HTTPoison.Response.t()
  def get_beatmapset!(id, opts \\ []) when is_integer(id),
    do: get!(:beatmaps, Keyword.put(opts, :s, id))

  @doc "Gets a user by username or user ID."
  @spec get_user(user, keyword) :: {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_user(user, opts \\ []) when is_user(user),
    do: get(:user, Keyword.merge(opts, u: user, type: user_type(user)))

  @doc "Same as `get_user/2` but returns just the response and can throw exceptions."
  @spec get_user!(user, keyword) :: HTTPoison.Response.t()
  def get_user!(user, opts \\ []) when is_user(user),
    do: get!(:user, Keyword.merge(opts, u: user, type: user_type(user)))

  @doc "Gets a beatmap's top scores."
  @spec get_scores(integer, keyword) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_scores(map_id, opts \\ []) when is_integer(map_id),
    do: get(:scores, Keyword.put(opts, :b, map_id))

  @doc "Same as `get_scores/2` but returns just the response and can throw exceptions."
  @spec get_scores!(integer, keyword) :: HTTPoison.Response.t()
  def get_scores!(map_id, opts \\ []) when is_integer(map_id),
    do: get!(:scores, Keyword.put(opts, :b, map_id))

  @doc "Gets a user's top scores."
  @spec get_user_best(user, keyword) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_user_best(user, opts \\ []) when is_user(user),
    do: get(:user_best, Keyword.merge(opts, u: user, type: user_type(user)))

  @doc "Same as `get_user_best/2` but returns just the response and can throw exceptions."
  @spec get_user_best!(user, keyword) :: HTTPoison.Response.t()
  def get_user_best!(user, opts \\ []) when is_user(user),
    do: get!(:user_best, Keyword.merge(opts, u: user, type: user_type(user)))

  @doc "Gets a user's recent scores."
  @spec get_user_recent(user, keyword) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_user_recent(user, opts \\ []) when is_user(user),
    do: get(:user_recent, Keyword.merge(opts, u: user, type: user_type(user)))

  @doc "Same as `get_user_recent/2` but returns just the response and can throw exceptions."
  @spec get_user_recent!(user, keyword) :: HTTPoison.Response.t()
  def get_user_recent!(user, opts \\ []) when is_user(user),
    do: get!(:user_recent, Keyword.merge(opts, u: user, type: user_type(user)))

  @doc "Gets a multiplayer match by ID."
  @spec get_match(integer, keyword) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_match(id, opts \\ []) when is_integer(id), do: get(:match, Keyword.put(opts, :mp, id))

  @doc "Same as `get_match/2` but returns just the response and can throw exceptions."
  @spec get_match!(integer, keyword) :: HTTPoison.Response.t()
  def get_match!(id, opts \\ []) when is_integer(id), do: get!(:match, Keyword.put(opts, :mp, id))

  @doc "Gets replay data for a score."
  @spec get_replay(integer, user, integer, keyword) ::
          {:ok, HTTPoison.Response.t()} | {:error, HTTPoison.Error.t()}
  def get_replay(map_id, user, mode, opts \\ [])
      when is_integer(map_id) and is_user(user) and is_integer(mode),
      do: get(:replay, Keyword.merge(opts, b: map_id, m: mode, u: user))

  @doc "Same as `get_replay/4` but returns just the response and can throw exceptions."
  @spec get_replay!(integer, user, integer, keyword) :: HTTPoison.Response.t()
  def get_replay!(map_id, user, mode, opts \\ [])
      when is_integer(map_id) and is_user(user) and is_integer(mode),
      do: get!(:replay, Keyword.merge(opts, b: map_id, m: mode, u: user))
end
