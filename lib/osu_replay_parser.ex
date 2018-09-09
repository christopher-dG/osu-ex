defmodule OsuReplayParser do
  @moduledoc "A parser for osu! replays (.osr files)."

  use Bitwise, only_operators: true

  @doc "Parse a replay file. The argument can be either the file path or the contents."
  @spec parse(binary) :: {:ok, map} | {:error, term}
  def parse(path_or_data) when is_binary(path_or_data) do
    try do
      {:ok, parse!(path_or_data)}
    rescue
      e -> {:error, e}
    end
  end

  @doc "Parse a replay file. The argument can be either the file path or the contents."
  @spec parse!(binary) :: map
  def parse!(path_or_data) when is_binary(path_or_data) do
    data = if(String.valid?(path_or_data), do: File.read!(path_or_data), else: path_or_data)

    %{data_: data, temp_: nil}
    |> read_byte(:mode)
    |> read_int(:version)
    |> read_string(:beatmap_md5)
    |> read_string(:player)
    |> read_string(:replay_md5)
    |> read_short(:n300)
    |> read_short(:n100)
    |> read_short(:n50)
    |> read_short(:ngeki)
    |> read_short(:nkatu)
    |> read_short(:nmiss)
    |> read_int(:score)
    |> read_short(:combo)
    |> read_byte(:perfect)
    |> read_int(:mods)
    |> read_string(:life_bar)
    |> read_long(:timestamp)
    |> read_replay_data(:replay_data)
    # https://github.com/omkelderman/osu-replay-downloader/blob/cb85fe9907dd2195eb54b2c459a54b8a963bc5c4/fetch.iced#L150-L153
    |> read_long(:replay_id)
    |> Map.drop([:data_, :temp_])
  end

  # Read a string from the binary and store it as k's value.
  @spec read_string(map, atom) :: map
  defp read_string(m, k) do
    m = read_byte(m, :temp_)

    if m.temp_ === 0 do
      Map.put(m, k, "")
    else
      m = read_uleb(m, :temp_)
      n = m.temp_
      <<s::binary-size(n), t::binary>> = m.data_
      %{m | data_: t} |> Map.put(k, s)
    end
  end

  # Read a ULEB128 encoded number and store it as k's value.
  @spec read_uleb(map, atom) :: map
  defp read_uleb(m, k), do: read_uleb(m, k, 0, 0)

  # https://en.wikipedia.org/wiki/LEB128#Decode_unsigned_integer
  defp read_uleb(m, k, acc, shift) do
    m = read_byte(m, :temp_)
    acc = acc ||| (m.temp_ &&& 0x7F) <<< shift

    if (m.temp_ &&& 0x80) === 0 do
      Map.put(m, k, acc)
    else
      read_uleb(m, k, acc, shift + 7)
    end
  end

  # Read n bytes from the binary and store it as k's value.
  @spec read_n(map, atom, integer) :: map
  defp read_n(m, k, n) do
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
    m = read_int(m, :temp_)
    n = m.temp_
    <<v::binary-size(n), t::binary>> = m.data_
    %{m | data_: t} |> Map.put(k, v)
  end
end
