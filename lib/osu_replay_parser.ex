defmodule OsuReplayParser do
  @moduledoc """
  Documentation for OsuReplayParser.
  """

  @doc "Parse the .osr file at `path`."
  @spec parse!(binary) :: map
  def parse!(path) when is_binary(path) do
    %{data_: File.read!(path), temp_: nil}
    |> read_byte(:mode)
    |> read_int(:date)
    # |> read_string(:beatmap_md5)
    # |> read_string(:player)
    # |> read_string(:replay_md5)
    # |> read_short(:n300)
    # |> read_short(:n100)
    # |> read_short(:n50)
    # |> read_short(:ngeki)
    # |> read_short(:nkatu)
    # |> read_short(:nmiss)
    # |> read_int(:score)
    # |> read_short(:combo)
    # |> read_byte(:perfect)
    # |> read_int(:mods)
    # |> read_string(:life_bar)
    # |> read_long(:timestamp)
    # |> read_int(:replay_length)
    # |> read_replay_data(:replay_data)
    |> Map.drop([:data_, :temp_])
  end

  # Read a string from the binary and store it as k's value.
  @spec read_string(map, atom) :: map
  defp read_string(m, k) do
    m = read_byte(m, :temp_)

    if m.temp_ === 0 do
      Map.put(m, k, "")
    else
      # Technically this case should be restricted to m.temp_ === 11, but whatever.
      m = read_uleb(m)
      n = m.temp_
      <<s::binary-size(n), t::binary>> = m.data_
      %{m | data_: t} |> Map.put(k, s)
    end
  end

  @spec read_uleb(map) :: map
  defp read_uleb(m) do
    # TODO
    m
  end

  # Read n bytes from the binary and store it as k's value.
  @spec read_n(map, atom, integer) :: map
  def read_n(m, k, n) do
    s = n * 8
    <<v::little-size(s), t::binary>> = m.data_
    %{m | data_: t} |> Map.put(k, v)
  end

  @spec read_byte(map, atom) :: map
  defp read_byte(m, k), do: read_n(m, k, 1)

  @spec read_short(map, atom) :: map
  defp read_short(m, k), do: read_n(m, k, 2)

  @spec read_int(map, atom) :: map
  defp read_int(m, k), do: read_n(m, k, 4)

  @spec read_long(map, atom) :: map
  defp read_long(m, k), do: read_n(m, k, 8)

  # Read raw replay data from the binary and store it as k's value.
  @spec read_replay_data(map, atom) :: map
  defp read_replay_data(m, k) do
    # TODO
    m
  end
end
