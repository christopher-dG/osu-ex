defmodule OsuAPITest do
  use ExUnit.Case

  test "response body value types are converted" do
    user = OsuAPI.get_user!("cookiezi")

    assert is_map(user)
    assert is_number(Map.get(user, :accuracy))
    assert is_integer(Map.get(user, :count100))
    assert is_integer(Map.get(user, :count300))
    assert is_integer(Map.get(user, :count50))
    assert is_integer(Map.get(user, :count_rank_a))
    assert is_integer(Map.get(user, :count_rank_s))
    assert is_integer(Map.get(user, :count_rank_sh))
    assert is_integer(Map.get(user, :count_rank_ss))
    assert is_integer(Map.get(user, :count_rank_ssh))
    assert is_binary(Map.get(user, :country))
    assert is_list(Map.get(user, :events))
    assert is_number(Map.get(user, :level))
    assert is_integer(Map.get(user, :playcount))
    assert is_number(Map.get(user, :accuracy))
    assert is_integer(Map.get(user, :pp_rank))
    assert is_integer(Map.get(user, :pp_country_rank))
    assert is_number(Map.get(user, :pp_raw))
    assert is_integer(Map.get(user, :ranked_score))
    assert is_integer(Map.get(user, :total_score))
    assert is_integer(Map.get(user, :user_id))
    assert is_binary(Map.get(user, :username))

    beatmap = OsuAPI.get_beatmap!(129_891)

    assert is_map(beatmap)
    assert is_atom(Map.get(beatmap, :approved))
    # DateTimes are structs, and structs are maps.
    assert is_map(Map.get(beatmap, :approved_date))
    assert is_map(Map.get(beatmap, :last_update))
    assert is_binary(Map.get(beatmap, :artist))
    assert is_integer(Map.get(beatmap, :beatmap_id))
    assert is_integer(Map.get(beatmap, :beatmapset_id))
    assert is_number(Map.get(beatmap, :bpm))
    assert is_binary(Map.get(beatmap, :creator))
    assert is_number(Map.get(beatmap, :difficultyrating))
    assert is_number(Map.get(beatmap, :diff_size))
    assert is_number(Map.get(beatmap, :diff_overall))
    assert is_number(Map.get(beatmap, :diff_approach))
    assert is_number(Map.get(beatmap, :diff_drain))
    assert is_integer(Map.get(beatmap, :hit_length))
    assert is_binary(Map.get(beatmap, :source))
    assert is_atom(Map.get(beatmap, :genre))
    assert is_atom(Map.get(beatmap, :language))
    assert is_binary(Map.get(beatmap, :title))
    assert is_integer(Map.get(beatmap, :total_length))
    assert is_binary(Map.get(beatmap, :version))
    assert is_binary(Map.get(beatmap, :file_md5))
    assert is_atom(Map.get(beatmap, :mode))
    assert is_list(Map.get(beatmap, :tags))
    assert is_integer(Map.get(beatmap, :favourite_count))
    assert is_integer(Map.get(beatmap, :playcount))
    assert is_integer(Map.get(beatmap, :passcount))
    assert is_integer(Map.get(beatmap, :max_combo))
  end

  test "get_first sets body to nil if no search results" do
    assert OsuAPI.get_user("_") === {:ok, nil}
    assert is_nil(OsuAPI.get_beatmap!(0))
  end

  test "get_beatmaps" do
    {:ok, beatmaps} = OsuAPI.get_beatmaps()
    assert is_list(beatmaps)
    assert length(beatmaps) === 500
    assert Enum.all?(beatmaps, fn b -> Map.has_key?(b, :beatmap_id) end)

    beatmaps = OsuAPI.get_beatmaps!()
    assert is_list(beatmaps)
    assert length(beatmaps) === 500
    assert Enum.all?(beatmaps, fn b -> Map.has_key?(b, :beatmap_id) end)
  end

  test "get_beatmap" do
    {:ok, beatmap} = OsuAPI.get_beatmap(129_891)
    assert is_map(beatmap)
    assert Map.get(beatmap, :beatmap_id) === 129_891

    beatmap = OsuAPI.get_beatmap!(129_891)
    assert is_map(beatmap)
    assert Map.get(beatmap, :beatmap_id) === 129_891
  end

  test "get_beatmapset" do
    {:ok, beatmapset} = OsuAPI.get_beatmapset(39804)
    assert is_list(beatmapset)
    assert length(beatmapset) === 5
    assert Enum.all?(beatmapset, fn b -> Map.get(b, :beatmapset_id) === 39804 end)

    beatmapset = OsuAPI.get_beatmapset!(39804)
    assert is_list(beatmapset)
    assert length(beatmapset) === 5
    assert Enum.all?(beatmapset, fn b -> Map.get(b, :beatmapset_id) === 39804 end)
  end

  test "get_user" do
    {:ok, user} = OsuAPI.get_user("cookiezi")
    assert is_map(user)
    assert Map.get(user, :user_id) === 124_493

    {:ok, user} = OsuAPI.get_user(124_493)
    assert is_map(user)
    assert Map.get(user, :user_id) === 124_493

    user = OsuAPI.get_user!("cookiezi")
    assert is_map(user)
    assert Map.get(user, :user_id) === 124_493

    user = OsuAPI.get_user!(124_493)
    assert is_map(user)
    assert Map.get(user, :user_id) === 124_493
  end

  test "get_scores" do
    {:ok, scores} = OsuAPI.get_scores(129_891)
    assert is_list(scores)
    assert length(scores) === 50
    assert Enum.all?(scores, fn s -> Map.has_key?(s, :score_id) end)

    scores = OsuAPI.get_scores!(129_891)
    assert is_list(scores)
    assert length(scores) === 50
    assert Enum.all?(scores, fn s -> Map.has_key?(s, :score_id) end)
  end

  test "get_user_best" do
    {:ok, user_best} = OsuAPI.get_user_best("cookiezi")
    assert is_list(user_best)
    assert length(user_best) === 10

    assert Enum.all?(user_best, fn s ->
             Map.get(s, :user_id) === 124_493 and Map.has_key?(s, :score)
           end)

    {:ok, user_best} = OsuAPI.get_user_best(124_493)
    assert is_list(user_best)
    assert length(user_best) === 10

    assert Enum.all?(user_best, fn s ->
             Map.get(s, :user_id) === 124_493 and Map.has_key?(s, :score)
           end)

    user_best = OsuAPI.get_user_best!("cookiezi")
    assert is_list(user_best)
    assert length(user_best) === 10

    assert Enum.all?(user_best, fn s ->
             Map.get(s, :user_id) === 124_493 and Map.has_key?(s, :score)
           end)

    user_best = OsuAPI.get_user_best!(124_493)
    assert is_list(user_best)
    assert length(user_best) === 10

    assert Enum.all?(user_best, fn s ->
             Map.get(s, :user_id) === 124_493 and Map.has_key?(s, :score)
           end)
  end

  test "get_user_recent" do
    # We can't guarantee recent plays, so no length checks.

    {:ok, user_recent} = OsuAPI.get_user_recent("cookiezi")
    assert is_list(user_recent)

    assert Enum.all?(user_recent, fn s ->
             Map.get(s, :user_id) === 124_493 and Map.has_key?(s, :score)
           end)

    {:ok, user_recent} = OsuAPI.get_user_recent(124_493)
    assert is_list(user_recent)

    assert Enum.all?(user_recent, fn s ->
             Map.get(s, :user_id) === 124_493 and Map.has_key?(s, :score)
           end)

    user_recent = OsuAPI.get_user_recent!("cookiezi")
    assert is_list(user_recent)

    assert Enum.all?(user_recent, fn s ->
             Map.get(s, :user_id) === 124_493 and Map.has_key?(s, :score)
           end)

    user_recent = OsuAPI.get_user_recent!(124_493)
    assert is_list(user_recent)

    assert Enum.all?(user_recent, fn s ->
             Map.get(s, :user_id) === 124_493 and Map.has_key?(s, :score)
           end)
  end

  @tag skip: "can't find a match, response body doesn't follow API docs"
  test "get_match" do
    {:ok, match} = OsuAPI.get_match(1_933_622)
    assert is_map(match)
    assert is_map(Map.get(match, :match))
    assert is_list(Map.get(match, :games))

    match = OsuAPI.get_match!(1_933_622)
    assert is_map(match)
    assert is_map(Map.get(match, :match))
    assert is_list(Map.get(match, :games))
  end

  test "get_replay" do
    {:ok, replay} = OsuAPI.get_replay(129_891, "cookiezi", 0)
    assert is_map(replay)
    assert is_binary(replay.content)
    assert replay.encoding === "base64"

    replay = OsuAPI.get_replay!(129_891, 124_493, 0)
    assert is_map(replay)
    assert is_binary(replay.content)
    assert replay.encoding === "base64"
  end

  test "mode" do
    assert OsuAPI.mode(0) === :standard
    assert OsuAPI.mode(1) === :taiko
    assert OsuAPI.mode(2) === :catch
    assert OsuAPI.mode(3) === :mania

    assert OsuAPI.mode(:standard) === 0
    assert OsuAPI.mode(:taiko) === 1
    assert OsuAPI.mode(:catch) === 2
    assert OsuAPI.mode(:mania) === 3
  end
end
