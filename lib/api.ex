defmodule OsuEx.API.Error do
  defexception reason: nil, value: nil
  @type t :: {:status_code | integer} | {:httpoison | HTTPoison.Error.t()}
  def message(e), do: inspect(e)
end

defmodule OsuEx.API do
  @moduledoc """
  A wrapper around the osu! API.

  ## Usage

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

  The `get_*` function names mirror the API itself as do the parameter names,
  which can be passed as a trailing keyword list.

  The returned data is mostly identical to the osu! API documentation,
  except for the following:

  * The return value of functions which return at most one result
    (`get_user/2` for example) is a map instead of a list containing one map.
    If no result is found, then the value is `nil`, instead of an empty list.
  * Numbers, booleans, dates, and lists are parsed to their native types.

  To parse enum values like `approved: 3` into more human-readable atoms,
  or encode/decode mods, see the `OsuEx.API.Utils` module.

  ## Configuration

  To access the osu! API, you need to provide an API key.
  You can pass the `k` parameter around if you want,
  but otherwise you can configure its value in `config.exs`:

      config :osu_api, api_key: "<your key here>"

  You can also set the `OSU_API_KEY` environment variable.
  """

  alias OsuEx.API.Error
  alias OsuEx.API.HTTP

  @type user :: binary | integer

  @spec get(binary, keyword) :: {:ok, [map]} | {:error, Error.t()}
  defp get(endpoint, params) when is_binary(endpoint) and is_list(params) do
    case HTTP.get(endpoint, [], params: Map.new(params)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:error, %Error{reason: :status_code, value: code}}

      {:error, err} ->
        {:error, %Error{reason: :httpoison, value: err}}
    end
  end

  @spec get!(binary, keyword) :: [map]
  defp get!(endpoint, params) when is_binary(endpoint) and is_list(params) do
    case get(endpoint, params) do
      {:ok, body} -> body
      {:error, err} -> raise err
    end
  end

  @spec get_first(binary, keyword) :: {:ok, map | nil} | {:error, Error.t()}
  defp get_first(endpoint, params) when is_binary(endpoint) and is_list(params) do
    case get(endpoint, params) do
      {:ok, [h | _t]} -> {:ok, h}
      {:ok, []} -> {:ok, nil}
      {:error, err} -> {:error, err}
    end
  end

  @spec get_first!(binary, keyword) :: map | nil
  defp get_first!(endpoint, params) when is_binary(endpoint) and is_list(params) do
    case get_first(endpoint, params) do
      {:ok, body} -> body
      {:error, err} -> raise err
    end
  end

  @doc "Gets beatmaps."
  @spec get_beatmaps(keyword) :: {:ok, [map]} | {:error, Error.t()}
  def get_beatmaps(opts \\ []) when is_list(opts) do
    get("beatmaps", opts)
  end

  @doc "Same as `get_beatmaps/2` but raises exceptions."
  @spec get_beatmaps!(keyword) :: [map]
  def get_beatmaps!(opts \\ []) when is_list(opts) do
    get!("beatmaps", opts)
  end

  @doc "Gets a beatmap by ID (beatmap ID, not beatmapset ID) or MD5."
  @spec get_beatmap(integer | binary, keyword) :: {:ok, map | nil} | {:error, Error.t()}
  def get_beatmap(id_or_md5, opts \\ [])
      when is_integer(id_or_md5) or (is_binary(id_or_md5) and is_list(opts)) do
    k = if(is_integer(id_or_md5), do: :b, else: :h)
    get_first("beatmaps", Keyword.put(opts, k, id_or_md5))
  end

  @doc "Same as `get_beatmap/2` but raises exceptions."
  @spec get_beatmap!(integer | binary, keyword) :: map | nil
  def get_beatmap!(id_or_md5, opts \\ [])
      when is_integer(id_or_md5) or (is_binary(id_or_md5) and is_list(opts)) do
    k = if(is_integer(id_or_md5), do: :b, else: :h)
    get_first!("beatmaps", Keyword.put(opts, k, id_or_md5))
  end

  @doc "Gets a beatmapset by ID (beatmapset ID, not beatmap ID)."
  @spec get_beatmapset(integer, keyword) :: {:ok, [map]} | {:error, Error.t()}
  def get_beatmapset(id, opts \\ []) when is_integer(id) and is_list(opts) do
    get("beatmaps", Keyword.put(opts, :s, id))
  end

  @doc "Same as `get_beatmapset/2` but raises exceptions."
  @spec get_beatmapset!(integer, keyword) :: [map]
  def get_beatmapset!(id, opts \\ []) when is_integer(id) and is_list(opts) do
    get!("beatmaps", Keyword.put(opts, :s, id))
  end

  @doc "Gets a user by username or user ID."
  @spec get_user(user, keyword) :: {:ok, map | nil} | {:error, Error.t()}
  def get_user(user, opts \\ []) when (is_binary(user) or is_integer(user)) and is_list(opts) do
    get_first("user", Keyword.put(opts, :u, user))
  end

  @doc "Same as `get_user/2` but raises exceptions."
  @spec get_user!(user, keyword) :: map | nil
  def get_user!(user, opts \\ []) when (is_binary(user) or is_integer(user)) and is_list(opts) do
    get_first!("user", Keyword.put(opts, :u, user))
  end

  @doc "Gets a beatmap's top scores."
  @spec get_scores(integer, keyword) :: {:ok, [map]} | {:error, Error.t()}
  def get_scores(map_id, opts \\ []) when is_integer(map_id) and is_list(opts) do
    get("scores", Keyword.put(opts, :b, map_id))
  end

  @doc "Same as `get_scores/2` but raises exceptions."
  @spec get_scores!(integer, keyword) :: [map]
  def get_scores!(map_id, opts \\ []) when is_integer(map_id) and is_list(opts) do
    get!("scores", Keyword.put(opts, :b, map_id))
  end

  @doc "Gets a user's top scores."
  @spec get_user_best(user, keyword) :: {:ok, [map]} | {:error, Error.t()}
  def get_user_best(user, opts \\ [])
      when (is_binary(user) or is_integer(user)) and is_list(opts) do
    get("user_best", Keyword.put(opts, :u, user))
  end

  @doc "Same as `get_user_best/2` but raises exceptions."
  @spec get_user_best!(user, keyword) :: [map]
  def get_user_best!(user, opts \\ [])
      when (is_binary(user) or is_integer(user)) and is_list(opts) do
    get!("user_best", Keyword.put(opts, :u, user))
  end

  @doc "Gets a user's recent scores."
  @spec get_user_recent(user, keyword) :: {:ok, [map]} | {:error, Error.t()}
  def get_user_recent(user, opts \\ [])
      when (is_binary(user) or is_integer(user)) and is_list(opts) do
    get("user_recent", Keyword.put(opts, :u, user))
  end

  @doc "Same as `get_user_recent/2` but raises exceptions."
  @spec get_user_recent!(user, keyword) :: [map]
  def get_user_recent!(user, opts \\ [])
      when (is_binary(user) or is_integer(user)) and is_list(opts) do
    get!("user_recent", Keyword.put(opts, :u, user))
  end

  @doc "Gets a multiplayer match by ID."
  @spec get_match(integer, keyword) :: {:ok, map | nil} | {:error, Error.t()}
  def get_match(id, opts \\ []) when is_integer(id) and is_list(opts) do
    get_first("match", Keyword.put(opts, :mp, id))
  end

  @doc "Same as `get_match/2` but raises exceptions."
  @spec get_match!(integer, keyword) :: map | nil
  def get_match!(id, opts \\ []) when is_integer(id) and is_list(opts) do
    get_first!("match", Keyword.put(opts, :mp, id))
  end

  @doc "Gets replay data for a score."
  @spec get_replay(integer, user, integer, keyword) :: {:ok, map | nil} | {:error, Error.t()}
  def get_replay(map_id, user, mode, opts \\ [])
      when is_integer(map_id) and (is_binary(user) or is_integer(user)) and is_integer(mode) and
             is_list(opts) do
    get("replay", Keyword.merge(opts, b: map_id, m: mode, u: user))
  end

  @doc "Same as `get_replay/4` but raises exceptions."
  @spec get_replay!(integer, user, integer, keyword) :: map | nil
  def get_replay!(map_id, user, mode, opts \\ [])
      when is_integer(map_id) and (is_binary(user) or is_integer(user)) and is_integer(mode) and
             is_list(opts) do
    get!("replay", Keyword.merge(opts, b: map_id, m: mode, u: user))
  end
end
