defmodule OsuEx.Parser do
  @moduledoc "Parsers for .db and .osr files."

  use Bitwise, only_operators: true

  @doc "Parse a replay file. The argument can be either the file path or the contents."
  @spec osr(binary) :: {:ok, map} | {:error, Exception.t()}
  def osr(path_or_data) when is_binary(path_or_data) do
    try do
      {:ok, osr!(path_or_data)}
    rescue
      e -> {:error, e}
    end
  end

  @doc "Same as `osr/1`, but raises exceptions."
  @spec osr!(binary) :: map
  def osr!(path_or_data) when is_binary(path_or_data) do
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

  @doc "Parse an osu!.db file. The argument can be either the file path or the contents."
  @spec osu_db(binary) :: {:ok, map} | {:error, Exception.t()}
  def osu_db(path_or_data) when is_binary(path_or_data) do
    try do
      {:ok, osu_db!(path_or_data)}
    rescue
      e -> {:error, e}
    end
  end

  @doc "Same as `osu_db/1`, but raises exceptions."
  @spec osu_db!(binary) :: map
  def osu_db!(path_or_data) when is_binary(path_or_data) do
    data = if(String.valid?(path_or_data), do: File.read!(path_or_data), else: path_or_data)

    %{data_: data}
    |> int(:version)
    |> int(:nfolders)
    |> bool(:account_unlocked)
    |> datetime(:unlock_date)
    |> string(:player)
    |> multiple(:beatmaps, &beatmap/1)
    |> int(:unknown)
    |> Map.delete(:data_)
  end

  @doc "Parse a collection.db file. The argument can be either the file path or the contents."
  @spec collection_db(binary) :: {:ok, map} | {:error, Exception.t()}
  def collection_db(path_or_data) when is_binary(path_or_data) do
    try do
      {:ok, collection_db!(path_or_data)}
    rescue
      e -> {:error, e}
    end
  end

  @doc "Same as `collection_db/1`, but raises exceptions."
  @spec collection_db!(binary) :: map
  def collection_db!(path_or_data) when is_binary(path_or_data) do
    data = if(String.valid?(path_or_data), do: File.read!(path_or_data), else: path_or_data)

    %{data_: data}
    |> int(:version)
    |> multiple(:collections, &collection/1)
    |> Map.delete(:data_)
  end

  @doc "Parse a scores.db file. The argument can be either the file path or the contents."
  @spec scores_db(binary) :: {:ok, map} | {:error, Exception.t()}
  def scores_db(path_or_data) when is_binary(path_or_data) do
    try do
      {:ok, scores_db!(path_or_data)}
    rescue
      e -> {:error, e}
    end
  end

  @doc "Same as `scores_db/1`, but raises exceptions."
  @spec scores_db!(binary) :: map
  def scores_db!(path_or_data) when is_binary(path_or_data) do
    data = if(String.valid?(path_or_data), do: File.read!(path_or_data), else: path_or_data)

    %{data_: data}
    |> int(:version)
    |> multiple(:beatmaps, &beatmap_scores/1)
    |> Map.delete(:data_)
  end

  # Helper functions

  @spec put_or_return(map, atom | nil, term) :: map | {map, term}
  defp put_or_return(m, k, v), do: if(is_nil(k), do: {m, v}, else: Map.put(m, k, v))

  # Read multiple items from the binary and optionally store it as k's value.
  @spec multiple(map, atom | nil) :: map | {map, [binary]}
  defp multiple(m, k \\ nil, f, into \\ []) do
    {m, n} = int(m)

    {m, xs} =
      if n === 0 do
        {m, []}
      else
        Enum.reduce(1..n, {m, []}, fn _, {m, xs} ->
          {m, x} = f.(m)
          {m, [x | xs]}
        end)
      end

    put_or_return(m, k, xs |> Enum.reverse() |> Enum.into(into))
  end

  @spec int_n(map, atom | nil, integer) :: map | {map, integer}
  defp int_n(m, k, n) do
    s = n * 8
    <<v::little-size(s), t::binary>> = m.data_
    m = %{m | data_: t}
    put_or_return(m, k, v)
  end

  @spec float_n(map, atom | nil, integer) :: map | {map, integer}
  defp float_n(m, k, n) do
    s = n * 8
    <<v::float-little-size(s), t::binary>> = m.data_
    m = %{m | data_: t}
    put_or_return(m, k, v)
  end

  @spec byte(map, atom | nil) :: map | {map, byte}
  defp byte(m, k \\ nil), do: int_n(m, k, 1)

  @spec short(map, atom | nil) :: map | {map, integer}
  defp short(m, k \\ nil), do: int_n(m, k, 2)

  @spec int(map, atom | nil) :: map | {map, integer}
  defp int(m, k \\ nil), do: int_n(m, k, 4)

  @spec long(map, atom | nil) :: map | {map, integer}
  defp long(m, k \\ nil), do: int_n(m, k, 8)

  @spec single(map, atom | nil) :: map | {map, float}
  defp single(m, k \\ nil), do: float_n(m, k, 4)

  @spec double(map, atom | nil) :: map | {map, float}
  defp double(m, k \\ nil), do: float_n(m, k, 8)

  @spec bool(map, atom | nil) :: map | {map, boolean}
  defp bool(m, k \\ nil) do
    {m, b} = int_n(m, nil, 1)
    put_or_return(m, k, not (b === 0))
  end

  @spec string(map, atom | nil) :: map | {map, binary}
  defp string(m, k \\ nil) do
    {m, b} = byte(m)

    {m, s} =
      if b === 0 do
        {m, ""}
      else
        {m, n} = uleb(m)
        <<s::binary-size(n), t::binary>> = m.data_
        {%{m | data_: t}, s}
      end

    put_or_return(m, k, s)
  end

  @spec bytes(map, atom) :: map | {map, binary}
  defp bytes(m, k) do
    {m, n} = int(m)
    <<v::binary-size(n), t::binary>> = m.data_
    put_or_return(%{m | data_: t}, k, v)
  end

  # https://github.com/worldwidewat/TicksToDateTime/blob/master/Web/Index.html

  @epoch_ticks 621_355_968_000_000_000
  @ticks_per_ms 10000

  @spec datetime(map, atom | nil) :: map | {map, DateTime.t()}
  defp datetime(m, k \\ nil) do
    {m, n} = long(m)
    ms_since_epoch = round((n - @epoch_ticks) / @ticks_per_ms)
    put_or_return(m, k, DateTime.from_unix!(ms_since_epoch, :millisecond))
  end

  # These ones never get stored directly, so they don't take a key.

  @spec uleb(map) :: {map, integer}
  defp uleb(m), do: uleb(m, 0, 0)

  @spec uleb(map, integer, integer) :: {map, integer}
  defp uleb(m, acc, shift) do
    # https://en.wikipedia.org/wiki/LEB128#Decode_unsigned_integer
    {m, b} = byte(m)
    acc = acc ||| (b &&& 0x7F) <<< shift

    if (b &&& 0x80) === 0 do
      {m, acc}
    else
      uleb(m, acc, shift + 7)
    end
  end

  @spec int_double(map) :: {map, {integer, float}}
  defp int_double(m) do
    {m, _} = byte(m)
    {m, i} = int(m)
    {m, _} = byte(m)
    {m, d} = double(m)
    {m, {i, d}}
  end

  @spec timing_point(map) :: {map, map}
  defp timing_point(m) do
    {m, bpm} = double(m)
    {m, offset} = double(m)
    {m, not_inherited?} = bool(m)
    {m, %{bpm: bpm, offset: offset, inherited?: not not_inherited?}}
  end

  @beatmap_version_cutoff 20_140_609

  @spec beatmap(map) :: {map, map}
  defp beatmap(m) do
    # TODO: We can use this size to recover from faults.
    {m, size} = int(m)
    {m, artist} = string(m)
    {m, artist_unicode} = string(m)
    {m, title} = string(m)
    {m, title_unicode} = string(m)
    {m, creator} = string(m)
    {m, difficulty} = string(m)
    {m, audio_filename} = string(m)
    {m, beatmap_md5} = string(m)
    {m, osu_filename} = string(m)
    {m, status} = byte(m)
    {m, ncircles} = short(m)
    {m, nsliders} = short(m)
    {m, nspinners} = short(m)
    {m, last_modified} = datetime(m)
    f = if(m.version < @beatmap_version_cutoff, do: &byte/1, else: &single/1)
    {m, approach_rate} = f.(m)
    {m, circle_size} = f.(m)
    {m, hp_drain} = f.(m)
    {m, overall_difficulty} = f.(m)
    {m, slider_velocity} = double(m)

    {m, stars_standard, stars_taiko, stars_catch, stars_mania} =
      if m.version >= @beatmap_version_cutoff do
        {m, ss} = multiple(m, nil, &int_double/1, %{})
        {m, st} = multiple(m, nil, &int_double/1, %{})
        {m, sc} = multiple(m, nil, &int_double/1, %{})
        {m, sm} = multiple(m, nil, &int_double/1, %{})
        {m, ss, st, sc, sm}
      else
        {m, nil, nil, nil, nil}
      end

    {m, drain_time} = int(m)
    {m, total_time} = int(m)
    {m, audio_preview} = int(m)
    {m, timing_points} = multiple(m, &timing_point/1)
    {m, beatmap_id} = int(m)
    {m, beatmapset_id} = int(m)
    {m, thid} = int(m)
    {m, grade_standard} = byte(m)
    {m, grade_taiko} = byte(m)
    {m, grade_catch} = byte(m)
    {m, grade_mania} = byte(m)
    {m, local_offset} = short(m)
    {m, stack_leniency} = single(m)
    {m, mode} = byte(m)
    {m, source} = string(m)
    {m, tags} = string(m)
    tags = String.split(tags, " ")
    {m, online_offset} = short(m)
    {m, font} = string(m)
    {m, unplayed?} = bool(m)
    {m, last_play} = datetime(m)
    {m, osz2?} = bool(m)
    {m, folder} = string(m)
    {m, last_check} = datetime(m)
    {m, ignore_beatmap_sound?} = bool(m)
    {m, ignore_beatmap_skin?} = bool(m)
    {m, disable_storyboard?} = bool(m)
    {m, disable_video?} = bool(m)
    {m, visual_override?} = bool(m)

    {m, unknown} =
      if m.version < @beatmap_version_cutoff do
        short(m)
      else
        {m, nil}
      end

    {m, last_modified2} = int(m)
    {m, scroll_speed} = byte(m)

    {m,
     %{
       size: size,
       artist: artist,
       artist_unicode: artist_unicode,
       title: title,
       title_unicode: title_unicode,
       creator: creator,
       difficulty: difficulty,
       audio_filename: audio_filename,
       beatmap_md5: beatmap_md5,
       osu_filename: osu_filename,
       status: status,
       ncircles: ncircles,
       nsliders: nsliders,
       nspinners: nspinners,
       last_modified: last_modified,
       approach_rate: approach_rate,
       circle_size: circle_size,
       hp_drain: hp_drain,
       overall_difficulty: overall_difficulty,
       slider_velocity: slider_velocity,
       stars_standard: stars_standard,
       stars_taiko: stars_taiko,
       stars_catch: stars_catch,
       stars_mania: stars_mania,
       drain_time: drain_time,
       total_time: total_time,
       audio_preview: audio_preview,
       timing_points: timing_points,
       beatmap_id: beatmap_id,
       beatmapset_id: beatmapset_id,
       thid: thid,
       grade_standard: grade_standard,
       grade_taiko: grade_taiko,
       grade_catch: grade_catch,
       grade_mania: grade_mania,
       local_offset: local_offset,
       stack_leniency: stack_leniency,
       mode: mode,
       source: source,
       tags: tags,
       online_offset: online_offset,
       font: font,
       unplayed?: unplayed?,
       last_play: last_play,
       osz2?: osz2?,
       folder: folder,
       last_check: last_check,
       ignore_beatmap_sound?: ignore_beatmap_sound?,
       ignore_beatmap_skin?: ignore_beatmap_skin?,
       disable_storyboard?: disable_storyboard?,
       disable_video?: disable_video?,
       visual_override?: visual_override?,
       unknown: unknown,
       last_modified2: last_modified2,
       scroll_speed: scroll_speed
     }}
  end

  @spec collection(map) :: {map, map}
  defp collection(m) do
    {m, name} = string(m)
    {m, beatmaps} = multiple(m, &string/1)
    {m, %{name: name, beatmaps: beatmaps}}
  end

  @spec beatmap_scores(map) :: {map, map}
  defp beatmap_scores(m) do
    {m, beatmap_md5} = string(m)
    {m, scores} = multiple(m, &score/1)
    {m, %{beatmap_md5: beatmap_md5, scores: scores}}
  end

  @spec score(map) :: {map, map}
  defp score(m) do
    # TODO: This format is almost exactly the same as a .osr file,
    # except that there's no replay data.
    {m, mode} = byte(m)
    {m, version} = int(m)
    {m, beatmap_md5} = string(m)
    {m, player} = string(m)
    {m, replay_md5} = string(m)
    {m, n300} = short(m)
    {m, n100} = short(m)
    {m, n50} = short(m)
    {m, ngeki} = short(m)
    {m, nkatu} = short(m)
    {m, nmiss} = short(m)
    {m, score} = int(m)
    {m, combo} = short(m)
    {m, perfect?} = bool(m)
    {m, mods} = int(m)
    {m, _} = string(m)
    {m, timestamp} = datetime(m)
    {m, _} = int(m)
    {m, score_id} = long(m)

    {m,
     %{
       mode: mode,
       version: version,
       beatmap_md5: beatmap_md5,
       player: player,
       replay_md5: replay_md5,
       n300: n300,
       n100: n100,
       n50: n50,
       ngeki: ngeki,
       nkatu: nkatu,
       nmiss: nmiss,
       score: score,
       combo: combo,
       perfect?: perfect?,
       mods: mods,
       timestamp: timestamp,
       score_id: score_id
     }}
  end
end
