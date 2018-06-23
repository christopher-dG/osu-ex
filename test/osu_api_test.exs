defmodule OsuAPITest do
  use ExUnit.Case
  doctest OsuAPI

  setup_all do
    Application.put_env(:osu_api, :api_key, System.get_env("OSU_API_KEY"))
  end

  test "get_user" do
    r = OsuAPI.get!(:user, u: "cookiezi")
    assert r.status_code === 200
    assert length(r.body) === 1

    c = hd(r.body)
    assert is_map(c)
    assert is_float(c.accuracy)
    assert is_integer(c.count100)
    assert is_integer(c.count300)
    assert is_integer(c.count50)
    assert is_integer(c.count_rank_a)
    assert is_integer(c.count_rank_s)
    assert is_integer(c.count_rank_sh)
    assert is_integer(c.count_rank_ss)
    assert is_integer(c.count_rank_ssh)
    assert is_binary(c.country)
    assert is_list(c.events)
    assert is_float(c.level)
    assert is_integer(c.playcount)
    assert is_integer(c.pp_rank)
    assert is_integer(c.pp_country_rank)
    assert is_float(c.pp_raw)
    assert is_integer(c.ranked_score)
    assert is_integer(c.total_score)
    assert is_integer(c.user_id)
    assert is_binary(c.username)
  end

  test "get_beatmaps" do
    r = OsuAPI.get!(:beatmaps, b: 129_891)
    assert r.status_code === 200
    assert length(r.body) === 1

    f = hd(r.body)
    assert is_map(f)
    assert is_atom(f.approved)
    # DateTimes are structs, and structs are maps.
    assert is_map(f.approved_date)
    assert is_map(f.last_update)
    assert is_binary(f.artist)
    assert is_integer(f.beatmap_id)
    assert is_integer(f.beatmapset_id)
    assert is_number(f.bpm)
    assert is_binary(f.creator)
    assert is_float(f.difficultyrating)
    assert is_number(f.diff_size)
    assert is_number(f.diff_overall)
    assert is_number(f.diff_approach)
    assert is_number(f.diff_drain)
    assert is_integer(f.hit_length)
    assert is_binary(f.source)
    assert is_atom(f.genre)
    assert is_atom(f.language)
    assert is_binary(f.title)
    assert is_integer(f.total_length)
    assert is_binary(f.version)
    assert is_binary(f.file_md5)
    assert is_atom(f.mode)
    assert is_list(f.tags)
    assert is_integer(f.favourite_count)
    assert is_integer(f.playcount)
    assert is_integer(f.passcount)
    assert is_integer(f.max_combo)
  end
end
