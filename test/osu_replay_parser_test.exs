defmodule OsuReplayParserTest do
  use ExUnit.Case
  doctest OsuReplayParser

  test "parse!/1" do
    replays =
      Path.wildcard("test/data/*.osr")
      |> Enum.map(&OsuReplayParser.parse!/1)

    Enum.each(replays, fn r -> assert is_map(r) end)
  end
end
