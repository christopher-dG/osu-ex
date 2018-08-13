defmodule OsuAPI.Error do
  defexception reason: nil, value: nil
  @type t :: {:status_code | integer} | {:httpoison | HTTPoison.Error.t()}
  def message(e), do: inspect(e)
end

defmodule OsuAPI do
  @moduledoc """
  A wrapper around the osu! API.

  # Usage

      iex> OsuAPI.get_user("cookiezi", event_days: 5)
      {:ok, %{user_id: 124493, username: "Cookiezi"}, ...}

  The `get_*` function names mirror the API itself as do the parameter names,
   which can be passed as a trailing keyword list.

  The returned data is mostly identical to the osu! API documentation,
  except for the following:

  * The return value of functions which return at most one result
    (`get_user/2` for example) is a map instead of a list containing one map.
    If no result is found, then the value is `nil`, instead of an empty list.
  * Numbers, booleans, dates, and lists are parsed to their native types,
    and enum values are converted to their symbolic values as atoms.
  * Enums named `*_id` have the suffix removed, since the atoms aren't IDs.

  # Configuration

  To access the osu! API, you need to provide an API key.
  You can pass the `k` parameter around if you want,
  but otherwise you can configure its value in `config.exs`:

      config :osu_api, api_key: "<your key here>"

  You can also set the `OSU_API_KEY` environment variable.
  """

  alias OsuAPI.Error

  @type user :: binary | integer

  defguardp is_endpoint(endpoint) when is_atom(endpoint) or is_binary(endpoint)
  defguardp is_user(user) when is_binary(user) or is_integer(user)

  @spec user_type(binary | integer) :: binary
  defp user_type(user) when is_user(user), do: if(is_binary(user), do: "string", else: "id")

  @spec get(atom, keyword) :: {:ok, [map]} | {:error, Error.t()}
  defp get(endpoint, params) when is_endpoint(endpoint) do
    case OsuAPI.HTTP.get("#{endpoint}", [], params: Map.new(params)) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %HTTPoison.Response{status_code: code}} ->
        {:error, %Error{reason: :status_code, value: code}}

      {:error, err} ->
        {:error, %Error{reason: :httpoison, value: err}}
    end
  end

  @spec get!(atom, keyword) :: [map]
  defp get!(endpoint, params) when is_endpoint(endpoint) do
    case get("#{endpoint}", params) do
      {:ok, body} -> body
      {:error, err} -> raise err
    end
  end

  @spec get_first(atom, keyword) :: {:ok, map | nil} | {:error, Error.t()}
  defp get_first(endpoint, params) when is_endpoint(endpoint) do
    case get(endpoint, params) do
      {:ok, [h | _t]} -> {:ok, h}
      {:ok, []} -> {:ok, nil}
      {:error, err} -> {:error, err}
    end
  end

  @spec get_first!(atom, keyword) :: map | nil
  defp get_first!(endpoint, params) do
    case get_first(endpoint, params) do
      {:ok, body} -> body
      {:error, err} -> raise err
    end
  end

  @doc "Gets beatmaps."
  @spec get_beatmaps(keyword) :: {:ok, [map]} | {:error, Error.t()}
  def get_beatmaps(opts \\ []), do: get(:beatmaps, opts)

  @doc "Same as `get_beatmaps/2` but throws exceptions."
  @spec get_beatmaps!(keyword) :: [map]
  def get_beatmaps!(opts \\ []), do: get!(:beatmaps, opts)

  @doc "Gets a beatmap by ID (beatmap ID, not beatmapset ID)."
  @spec get_beatmap(integer, keyword) :: {:ok, map | nil} | {:error, Error.t()}
  def get_beatmap(id, opts \\ []) when is_integer(id),
    do: get_first(:beatmaps, Keyword.put(opts, :b, id))

  @doc "Same as `get_beatmap/2` but throws exceptions."
  @spec get_beatmap!(integer, keyword) :: map | nil
  def get_beatmap!(id, opts \\ []) when is_integer(id),
    do: get_first!(:beatmaps, Keyword.put(opts, :b, id))

  @doc "Gets a beatmapset by ID (beatmapset ID, not beatmap ID)."
  @spec get_beatmapset(integer, keyword) :: {:ok, [map]} | {:error, Error.t()}
  def get_beatmapset(id, opts \\ []) when is_integer(id),
    do: get(:beatmaps, Keyword.put(opts, :s, id))

  @doc "Same as `get_beatmapset/2` but throws exceptions."
  @spec get_beatmapset!(integer, keyword) :: [map]
  def get_beatmapset!(id, opts \\ []) when is_integer(id),
    do: get!(:beatmaps, Keyword.put(opts, :s, id))

  @doc "Gets a user by username or user ID."
  @spec get_user(user, keyword) :: {:ok, map | nil} | {:error, Error.t()}
  def get_user(user, opts \\ []) when is_user(user),
    do: get_first(:user, Keyword.merge(opts, u: user, type: user_type(user)))

  @doc "Same as `get_user/2` but throws exceptions."
  @spec get_user!(user, keyword) :: map | nil
  def get_user!(user, opts \\ []) when is_user(user),
    do: get_first!(:user, Keyword.merge(opts, u: user, type: user_type(user)))

  @doc "Gets a beatmap's top scores."
  @spec get_scores(integer, keyword) :: {:ok, [map]} | {:error, Error.t()}
  def get_scores(map_id, opts \\ []) when is_integer(map_id),
    do: get(:scores, Keyword.put(opts, :b, map_id))

  @doc "Same as `get_scores/2` but throws exceptions."
  @spec get_scores!(integer, keyword) :: [map]
  def get_scores!(map_id, opts \\ []) when is_integer(map_id),
    do: get!(:scores, Keyword.put(opts, :b, map_id))

  @doc "Gets a user's top scores."
  @spec get_user_best(user, keyword) :: {:ok, [map]} | {:error, Error.t()}
  def get_user_best(user, opts \\ []) when is_user(user),
    do: get(:user_best, Keyword.merge(opts, u: user, type: user_type(user)))

  @doc "Same as `get_user_best/2` but throws exceptions."
  @spec get_user_best!(user, keyword) :: [map]
  def get_user_best!(user, opts \\ []) when is_user(user),
    do: get!(:user_best, Keyword.merge(opts, u: user, type: user_type(user)))

  @doc "Gets a user's recent scores."
  @spec get_user_recent(user, keyword) :: {:ok, [map]} | {:error, Error.t()}
  def get_user_recent(user, opts \\ []) when is_user(user),
    do: get(:user_recent, Keyword.merge(opts, u: user, type: user_type(user)))

  @doc "Same as `get_user_recent/2` but throws exceptions."
  @spec get_user_recent!(user, keyword) :: [map]
  def get_user_recent!(user, opts \\ []) when is_user(user),
    do: get!(:user_recent, Keyword.merge(opts, u: user, type: user_type(user)))

  @doc "Gets a multiplayer match by ID."
  @spec get_match(integer, keyword) :: {:ok, map | nil} | {:error, Error.t()}
  def get_match(id, opts \\ []) when is_integer(id),
    do: get_first(:match, Keyword.put(opts, :mp, id))

  @doc "Same as `get_match/2` but throws exceptions."
  @spec get_match!(integer, keyword) :: map | nil
  def get_match!(id, opts \\ []) when is_integer(id),
    do: get_first!(:match, Keyword.put(opts, :mp, id))

  @doc "Gets replay data for a score."
  @spec get_replay(integer, user, integer, keyword) :: {:ok, map | nil} | {:error, Error.t()}
  def get_replay(map_id, user, mode, opts \\ [])
      when is_integer(map_id) and is_user(user) and is_integer(mode),
      do: get(:replay, Keyword.merge(opts, b: map_id, m: mode, u: user))

  @doc "Same as `get_replay/4` but throws exceptions."
  @spec get_replay!(integer, user, integer, keyword) :: map | nil
  def get_replay!(map_id, user, mode, opts \\ [])
      when is_integer(map_id) and is_user(user) and is_integer(mode),
      do: get!(:replay, Keyword.merge(opts, b: map_id, m: mode, u: user))
end
