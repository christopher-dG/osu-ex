defmodule OsuAPITest do
  use ExUnit.Case
  doctest OsuAPI

  setup_all do
    Application.put_env(:osu_api, :api_key, System.get_env("OSU_API_KEY"))
  end

  test "type inference" do
    r = OsuAPI.get!(:user, u: "cookiezi")
    assert r.status_code === 200
    assert length(r.body) === 1

    c = hd(r.body)
    assert is_map(c)
    assert is_number(c.accuracy)
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
    assert is_number(c.level)
    assert is_integer(c.playcount)
    assert is_integer(c.pp_rank)
    assert is_integer(c.pp_country_rank)
    assert is_number(c.pp_raw)
    assert is_integer(c.ranked_score)
    assert is_integer(c.total_score)
    assert is_integer(c.user_id)
    assert is_binary(c.username)

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
    assert is_number(f.difficultyrating)
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

  test "get_first sets body to nil if no search results" do
    {:ok, r} = OsuAPI.get_user("_")
    assert r.status_code === 200
    assert is_nil(r.body)

    r = OsuAPI.get_beatmap!(0)
    assert r.status_code === 200
    assert is_nil(r.body)
  end

  test "get_beatmaps" do
    {:ok, r} = OsuAPI.get_beatmaps()
    assert r.status_code === 200
    assert is_list(r.body)
    assert length(r.body) === 500
    assert Enum.all?(r.body, fn b -> Map.has_key?(b, :beatmap_id) end)

    r = OsuAPI.get_beatmaps!()
    assert r.status_code === 200
    assert is_list(r.body)
    assert length(r.body) === 500
    assert Enum.all?(r.body, fn b -> Map.has_key?(b, :beatmap_id) end)
  end

  test "get_beatmap" do
    {:ok, r} = OsuAPI.get_beatmap(129_891)
    assert r.status_code === 200
    assert is_map(r.body)
    assert Map.get(r.body, :beatmap_id) === 129_891

    r = OsuAPI.get_beatmap!(129_891)
    assert r.status_code === 200
    assert is_map(r.body)
    assert Map.get(r.body, :beatmap_id) === 129_891
  end

  test "get_beatmapset" do
    {:ok, r} = OsuAPI.get_beatmapset(39804)
    assert r.status_code === 200
    assert is_list(r.body)
    assert length(r.body) === 5
    assert Enum.all?(r.body, fn b -> Map.get(b, :beatmapset_id) === 39804 end)

    r = OsuAPI.get_beatmapset!(39804)
    assert r.status_code === 200
    assert is_list(r.body)
    assert length(r.body) === 5
    assert Enum.all?(r.body, fn b -> Map.get(b, :beatmapset_id) === 39804 end)
  end

  test "get_user" do
    {:ok, r} = OsuAPI.get_user("cookiezi")
    assert r.status_code === 200
    assert is_map(r.body)
    assert Map.get(r.body, :user_id) === 124_493

    {:ok, r} = OsuAPI.get_user(124_493)
    assert r.status_code === 200
    assert is_map(r.body)
    assert Map.get(r.body, :user_id) === 124_493

    r = OsuAPI.get_user!("cookiezi")
    assert r.status_code === 200
    assert is_map(r.body)
    assert Map.get(r.body, :user_id) === 124_493

    r = OsuAPI.get_user!(124_493)
    assert r.status_code === 200
    assert is_map(r.body)
    assert Map.get(r.body, :user_id) === 124_493
  end

  test "get_scores" do
    {:ok, r} = OsuAPI.get_scores(129_891)
    assert r.status_code === 200
    assert is_list(r.body)
    assert length(r.body) === 50
    assert Enum.all?(r.body, fn s -> Map.has_key?(s, :score_id) end)

    r = OsuAPI.get_scores!(129_891)
    assert r.status_code === 200
    assert is_list(r.body)
    assert length(r.body) === 50
    assert Enum.all?(r.body, fn s -> Map.has_key?(s, :score_id) end)
  end

  test "get_user_best" do
    {:ok, r} = OsuAPI.get_user_best("cookiezi")
    assert r.status_code === 200
    assert is_list(r.body)
    assert length(r.body) === 10

    assert Enum.all?(r.body, fn s ->
      Map.get(s, :user_id) === 124_493 and Map.has_key?(s, :score)
           end)

    {:ok, r} = OsuAPI.get_user_best(124_493)
    assert r.status_code === 200
    assert is_list(r.body)
    assert length(r.body) === 10

    assert Enum.all?(r.body, fn s ->
             Map.get(s, :user_id) === 124_493 and Map.has_key?(s, :score)
           end)

    r = OsuAPI.get_user_best!("cookiezi")
    assert r.status_code === 200
    assert is_list(r.body)
    assert length(r.body) === 10

    assert Enum.all?(r.body, fn s ->
             Map.get(s, :user_id) === 124_493 and Map.has_key?(s, :score)
           end)

    r = OsuAPI.get_user_best!(124_493)
    assert r.status_code === 200
    assert is_list(r.body)
    assert length(r.body) === 10

    assert Enum.all?(r.body, fn s ->
             Map.get(s, :user_id) === 124_493 and Map.has_key?(s, :score)
           end)
  end

  test "get_user_recent" do
    # We can't guarantee recent plays, so no length checks.

    {:ok, r} = OsuAPI.get_user_recent("cookiezi")
    assert r.status_code === 200
    assert is_list(r.body)

    assert Enum.all?(r.body, fn s ->
             Map.get(s, :user_id) === 124_493 and Map.has_key?(s, :score)
           end)

    {:ok, r} = OsuAPI.get_user_recent(124_493)
    assert r.status_code === 200
    assert is_list(r.body)

    assert Enum.all?(r.body, fn s ->
             Map.get(s, :user_id) === 124_493 and Map.has_key?(s, :score)
           end)

    r = OsuAPI.get_user_recent!("cookiezi")
    assert r.status_code === 200
    assert is_list(r.body)

    assert Enum.all?(r.body, fn s ->
             Map.get(s, :user_id) === 124_493 and Map.has_key?(s, :score)
           end)

    r = OsuAPI.get_user_recent!(124_493)
    assert r.status_code === 200
    assert is_list(r.body)

    assert Enum.all?(r.body, fn s ->
             Map.get(s, :user_id) === 124_493 and Map.has_key?(s, :score)
           end)
  end

  test "get_match" do
    {:ok, r} = OsuAPI.get_match(1_933_622)
    assert r.status_code === 200
    assert is_map(r.body)
    assert is_list(Map.get(r.body, :games))
    # This returns %{games: [], match: 0}, I'm not sure if it's user error.
  end

  test "get_replay" do
    {:ok, r} = OsuAPI.get_replay(129_891, "cookiezi", 0)
    assert r.status_code === 200
    assert is_map(r.body)
    assert is_binary(r.body.content)
    assert r.body.encoding === "base64"

    r = OsuAPI.get_replay!(129_891, 124_493, 0)
    assert r.status_code === 200
    assert is_map(r.body)
    assert is_binary(r.body.content)
    assert r.body.encoding === "base64"
  end
end
