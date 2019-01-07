defmodule OsuEx.Osr do
  @moduledoc "Parses and downloads .osr files."

  alias OsuEx.API
  import OsuEx.Parser
  use Bitwise, only_operators: true

  @doc "Parses a replay file. The argument can be either the file path or the contents."
  @spec parse(binary) :: {:ok, map} | {:error, Exception.t()}
  def parse(path_or_data) do
    try do
      {:ok, parse!(path_or_data)}
    rescue
      e -> {:error, e}
    end
  end

  @doc "Same as `parse/1`, but raises exceptions."
  @spec parse!(binary) :: map
  def parse!(path_or_data) do
    data = if(String.valid?(path_or_data), do: File.read!(path_or_data), else: path_or_data)

    %{data_: data}
    |> byte(:mode)
    |> int(:version)
    |> string(:beatmap_md5)
    |> string(:player)
    |> string(:replay_md5)
    |> short(:n300)
    |> short(:n100)
    |> short(:n50)
    |> short(:ngeki)
    |> short(:nkatu)
    |> short(:nmiss)
    |> int(:score)
    |> short(:combo)
    |> bool(:perfect?)
    |> int(:mods)
    |> string(:life_bar)
    |> datetime(:timestamp)
    |> bytes(:replay_data)
    |> long(:replay_id)
    |> Map.delete(:data_)
  end

  @game_v 20_151_228

  @doc "Downloads a replay file."
  @spec download_replay(pos_integer, API.user_id(), keyword) :: {:ok, binary} | {:error, term}
  def download_replay(beatmap, player, opts \\ []) do
    mode = Keyword.get(opts, :m, 0)
    mods = Keyword.get(opts, :mods)
    scores_opts = [u: player, m: mode] ++ if(is_nil(mods), do: [], else: [mods: mods])
    replay_opts = if(is_nil(mods), do: [], else: [mods: mods])

    with {:ok, [%{replay_available: true} = score]} <- API.get_scores(beatmap, scores_opts),
         md5 when is_binary(md5) <-
           Keyword.get_lazy(opts, :h, fn ->
             case API.get_beatmap(beatmap) do
               {:ok, %{file_md5: md5}} -> md5
               {:ok, _} -> {:error, :no_md5}
               {:error, reason} -> {:error, reason}
             end
           end),
         {:ok, %{content: content}} <- API.get_replay(beatmap, player, mode, replay_opts),
         {:ok, replay} <- Base.decode64(content) do
      hash_data =
        :md5
        |> :crypto.hash("#{score.maxcombo}osu#{score.username}#{md5}#{score.score}#{score.rank}")
        |> Base.encode16()
        |> String.downcase()

      osr =
        []
        |> add_bytes(mode)
        |> add_int(@game_v)
        |> add_string(md5)
        |> add_string(score.username)
        |> add_string(hash_data)
        |> add_short(score.count300)
        |> add_short(score.count100)
        |> add_short(score.count50)
        |> add_short(score.countgeki)
        |> add_short(score.countkatu)
        |> add_short(score.countmiss)
        |> add_int(score.score)
        |> add_short(score.maxcombo)
        |> add_bytes(score.perfect)
        |> add_int(score.enabled_mods)
        |> add_string("")
        |> add_timestamp(score.date)
        |> add_int(byte_size(replay))
        |> add_bytes(replay)
        |> add_long(score.score_id)
        |> :binary.list_to_bin()

      {:ok, osr}
    else
      {:ok, []} -> {:error, :score_not_found}
      {:ok, %{error: reason}} -> {:error, reason}
      {:ok, [%{replay_available: false}]} -> {:error, :replay_not_available}
      {:ok, _} -> {:error, :invalid_replay}
      :error -> {:error, :invalid_replay}
      {:error, reason} -> {:error, reason}
      other -> {:error, {:invalid, other}}
    end
  end

  defp add_n_bytes(data, bs, n) do
    s = n * 8
    [data, <<bs::little-size(s)>>]
  end

  defp add_bytes(data, b) when is_boolean(b) do
    add_bytes(data, if(b, do: 1, else: 0))
  end

  defp add_bytes(data, bs) do
    [data, bs]
  end

  defp add_short(data, s) do
    add_n_bytes(data, s, 2)
  end

  defp add_int(data, i) do
    add_n_bytes(data, i, 4)
  end

  defp encode_uleb(i, acc \\ [])

  defp encode_uleb(0, acc) do
    acc
  end

  defp encode_uleb(i, acc) do
    # https://en.wikipedia.org/wiki/LEB128#Encode_unsigned_integer
    b = i &&& 0x7F
    i = i >>> 7
    b = if(i === 0, do: b, else: b ||| 0x80)
    encode_uleb(i, [acc, b])
  end

  defp add_string(data, "") do
    add_bytes(data, 0x00)
  end

  defp add_string(data, s) do
    len =
      s
      |> String.length()
      |> encode_uleb()

    [data, 0x0B, len, s]
  end

  defp add_long(data, l) do
    add_n_bytes(data, l, 8)
  end

  # https://github.com/worldwidewat/TicksToDateTime/blob/master/Web/Index.html

  @epoch_ticks 621_355_968_000_000_000
  @ticks_per_ms 10000

  defp to_ticks(dt) do
    DateTime.to_unix(dt, :millisecond) * @ticks_per_ms + @epoch_ticks
  end

  defp add_timestamp(data, dt) do
    ticks = to_ticks(dt)
    add_long(data, ticks)
  end
end
