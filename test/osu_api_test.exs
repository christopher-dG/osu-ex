defmodule OsuAPITest do
  use ExUnit.Case
  doctest OsuAPI

  test "greets the world" do
    assert OsuAPI.hello() == :world
  end
end
