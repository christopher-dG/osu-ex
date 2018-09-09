defmodule OsuReplayParserTest do
  use ExUnit.Case
  doctest OsuReplayParser

  @testfile "test/data/cookiezi-fd4d.osr"

  test "parse!/1 (file path)" do
    @testfile |> OsuReplayParser.parse!() |> assert()
  end

  test "parse!/1 (file contents)" do
    @testfile |> OsuReplayParser.parse!() |> assert()
  end

  defp asserts(d) do
    assert d.beatmap_md5 === "da8aae79c8f3306b5d65ec951874a7fb"
    assert d.combo === 2385
    assert d.life_bar === ""
    assert d.mode === 0
    assert d.mods === 24
    assert d.n100 === 5
    assert d.n300 === 1978
    assert d.n50 === 0
    assert d.ngeki === 247
    assert d.nkatu === 4
    assert d.nmiss === 0
    assert d.perfect === 1
    assert d.player === "Cookiezi"
    assert byte_size(d.replay_data) === 119_417
    assert d.replay_id === 2_177_560_145
    assert d.replay_md5 === "f0225807e33a0fb2fff5a303ef31134a"
    assert d.score === 132_408_001
    assert d.timestamp === 635_873_755_112_646_784
    assert d.version === 20_151_228
    assert map_size(d) === 19
  end
end
