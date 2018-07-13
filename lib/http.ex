defmodule OsuAPI.HTTP do
  @moduledoc "The underlying osu! API HTTP wrapper."

  use HTTPoison.Base

  @base_url "https://osu.ppy.sh/api"

  def process_url(url), do: "#{@base_url}/get_#{url}"

  def process_request_options(options) do
    api_key = Application.get_env(:osu_api, :api_key)
    Keyword.update(options, :params, %{k: api_key}, &Map.put_new(&1, :k, api_key))
  end

  def process_response_body(body) do
    case Jason.decode(body) do
      {:ok, data} -> process(data)
      {:error, _} -> body
    end
  end

  # Response body JSON parsing.

  # String lists.
  defp process({"tags", v}), do: {:tags, String.split(v)}

  # Booleans.
  defp process({"perfect", v}), do: {:perfect, v == "1"}
  defp process({"replay_available", v}), do: {:replay_available, v == "1"}

  # These fields should always be strings but can appear as numbers.
  defp process({"artist", v}), do: {:artist, v}
  defp process({"creator", v}), do: {:creator, v}
  defp process({"file_md5", v}), do: {:file_md5, v}
  defp process({"title", v}), do: {:title, v}
  defp process({"username", v}), do: {:username, v}
  defp process({"version", v}), do: {:version, v}

  # Special cased types.
  defp process({k, nil}), do: {String.to_atom(k), nil}
  defp process({k, v}) when is_integer(v), do: {String.to_atom(k), v}

  # Enums.

  defp process({"approved", v}) do
    {:approved,
     case v do
       "-2" -> :graveyard
       "-1" -> :wip
       "0" -> :pending
       "1" -> :ranked
       "2" -> :approved
       "3" -> :qualified
       "4" -> :loved
       _ -> process(v)
     end}
  end

  defp process({"genre_id", v}) do
    # Note that we rename the key to just :genre here.
    {:genre,
     case v do
       "0" -> :any
       "1" -> :unspecified
       "2" -> :video_game
       "3" -> :anime
       "4" -> :rock
       "5" -> :pop
       "6" -> :other
       "7" -> :novelty
       "9" -> :hip_hop
       "10" -> :electronic
       _ -> v
     end}
  end

  defp process({"language_id", v}) do
    # Note that we rename the key to just :language here.
    {:language,
     case v do
       "0" -> :any
       "1" -> :other
       "2" -> :english
       "3" -> :japanese
       "4" -> :chinese
       "5" -> :instrumental
       "6" -> :korean
       "7" -> :french
       "8" -> :german
       "9" -> :swedish
       "10" -> :spanish
       "11" -> :italian
       _ -> process(v)
     end}
  end

  defp process({"mode", v}) do
    {:mode,
     case v do
       "0" -> :standard
       "1" -> :taiko
       "2" -> :catch
       "3" -> :mania
       _ -> process(v)
     end}
  end

  defp process({"play_mode", v}) do
    {:play_mode,
     case v do
       "0" -> :standard
       "1" -> :taiko
       "2" -> :catch
       "3" -> :mania
       _ -> process(v)
     end}
  end

  defp process({"scoring_type", v}) do
    {:scoring_type,
     case v do
       "0" -> :score
       "1" -> :accuracy
       "2" -> :combo
       "3" -> :score_v2
       _ -> process(v)
     end}
  end

  defp process({"team_type", v}) do
    {:team_type,
     case v do
       "0" -> :head_to_head
       "1" -> :tag_coop
       "2" -> :team_vs
       "3" -> :tag_team_vs
       _ -> process(v)
     end}
  end

  defp process({"team", v}) do
    {:team,
     case v do
       "1" -> :blue
       "2" -> :red
       _ -> process(v)
     end}
  end

  # Process collections recursively.
  defp process(list) when is_list(list), do: Enum.map(list, &process/1)
  defp process(map) when is_map(map), do: map |> Enum.map(&process/1) |> Map.new()

  # General cases.
  defp process({k, v}), do: {String.to_atom(k), process(v)}

  defp process(scalar) do
    case Integer.parse(scalar) do
      {i, ""} ->
        i

      _ ->
        case Float.parse(scalar) do
          {f, ""} ->
            f

          _ ->
            case DateTime.from_iso8601(scalar <> "Z") do
              {:ok, d, _} -> d
              _ -> scalar
            end
        end
    end
  end
end
