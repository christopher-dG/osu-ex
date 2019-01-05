defmodule OsuEx.ScoresDB do
  @moduledoc "Parses scores.db files."

  import OsuEx.Parser

  @doc "Parses a scores.db file. The argument can be either the file path or the contents."
  @spec parse(binary) :: {:ok, map} | {:error, Exception.t()}
  def parse(path_or_data) do
    try do
      {:ok, parse!(path_or_data)}
    rescue
      e -> {:error, e}
    end
  end

  @doc "Same as `parse/1`, but raises exceptions."
  @spec parse!(binary) :: map
  def parse!(path_or_data) do
    data = if(String.valid?(path_or_data), do: File.read!(path_or_data), else: path_or_data)

    %{data_: data}
    |> int(:version)
    |> multiple(:beatmaps, &beatmap_scores/1)
    |> Map.delete(:data_)
  end
end
