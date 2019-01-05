defmodule OsuEx.CollectionDB do
  @moduledoc "Parsers collection.db files."

  import OsuEx.Parser

  @doc "Parses a collection.db file. The argument can be either the file path or the contents."
  @spec collection_db(binary) :: {:ok, map} | {:error, Exception.t()}
  def collection_db(path_or_data) do
    try do
      {:ok, collection_db!(path_or_data)}
    rescue
      e -> {:error, e}
    end
  end

  @doc "Same as `collection_db/1`, but raises exceptions."
  @spec collection_db!(binary) :: map
  def collection_db!(path_or_data) do
    data = if(String.valid?(path_or_data), do: File.read!(path_or_data), else: path_or_data)

    %{data_: data}
    |> int(:version)
    |> multiple(:collections, &collection/1)
    |> Map.delete(:data_)
  end
end
