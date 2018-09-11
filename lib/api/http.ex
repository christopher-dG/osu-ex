defmodule OsuEx.API.HTTP do
  @moduledoc "The underlying osu! API HTTP wrapper."

  use HTTPoison.Base

  @base_url "https://osu.ppy.sh/api"

  def process_url(url), do: "#{@base_url}/get_#{url}"

  def process_request_options(options) do
    case Keyword.fetch(options, :params) do
      {:ok, params} ->
        # Add the API key.
        api_key = Application.get_env(:osu_ex, :api_key, System.get_env("OSU_API_KEY"))
        params = Map.put_new(params, :k, api_key)

        # If the request has a user parameter, infer the type.
        params =
          case Map.fetch(params, :u) do
            {:ok, u} -> Map.put_new(params, :type, if(is_integer(u), do: "id", else: "string"))
            :error -> params
          end

        Keyword.put(options, :params, params)

      :error ->
        options
    end
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
