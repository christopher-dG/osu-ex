defmodule OsuAPI.HTTP do
  @moduledoc "The underlying osu! API HTTP wrapper."

  use HTTPoison.Base

  @base_url "https://osu.ppy.sh/api"

  def process_url(url), do: "#{@base_url}/get_#{url}"

  def process_request_options(options) do
    api_key = Application.get_env(:osu_api, :api_key)
    Keyword.update(options, :params, %{k: api_key}, &Map.put_new(&1, :k, api_key))
  end

  # Process each list element.
  defp process(list) when is_list(list), do: Enum.map(list, &process/1)
  # Convert each map key to an atom and process each map value.
  defp process(map) when is_map(map) do
    Enum.map(map, fn {k, v} -> {String.to_atom(k), process(v)} end)
  end

  defp process(nil), do: nil
  # Parse integers, floats, and dates into their native types.
  defp process(scalar) do
    case Integer.parse(scalar) do
      {i, ""} ->
        i

      _ ->
        case Float.parse(scalar) do
          {f, ""} ->
            f

          _ ->
            case NaiveDateTime.from_iso8601(scalar) do
              {:ok, n} ->
                n

              _ ->
                scalar
            end
        end
    end
  end

  def process_response_body(body) do
    case Poison.decode(body) do
      {:ok, data} ->
        process(data)

      {:error, _} ->
        body
    end
  end
end
