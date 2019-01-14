defmodule OsuEx.Utils do
  @moduledoc "Utility functions."

  use Bitwise, only_operators: true

  @mods [
    :NF,
    :EZ,
    :TD,
    :HD,
    :HR,
    :SD,
    :DT,
    :RL,
    :HT,
    :NC,
    :FL,
    :AT,
    :SO,
    :AP,
    :PF,
    :K4,
    :K5,
    :K6,
    :K7,
    :K8,
    :FI,
    :RN,
    :CN,
    :TG,
    :K9,
    :KC,
    :K1,
    :K3,
    :K2,
    :V2,
    :LM
  ]
  @mod_to_num @mods
              |> Enum.with_index()
              |> Enum.map(fn {m, i} -> {m, round(:math.pow(2, i))} end)
              |> Enum.into(%{})

  @doc """
  Translates bitwise mods into a list of atoms and vice versa.
  This function does not handle the `KeyMod`, `FreeModAllowed`, or `ScoreIncreaseMods`.

  ## Examples
      iex> OsuEx.API.Utils.mods(24) |> elem(1) |> MapSet.to_list()
      [:HD, :HR]

      iex> OsuEx.API.Utils.mods([:DT, :FL])
      {:ok, 1088}

      iex> OsuEx.API.Utils.mods([:QQ])
      {:error, {:unknown_mod, :QQ}}
  """
  def mods(_m)

  @spec mods(0..2_147_483_647) :: {:ok, MapSet.t()}
  def mods(n) when is_integer(n) do
    l =
      Enum.reduce(@mod_to_num, [], fn {m, i}, acc ->
        if((i &&& n) === i, do: acc ++ [m], else: acc)
      end)

    l = if(Enum.member?(l, :NC), do: List.delete(l, :DT), else: l)
    l = if(Enum.member?(l, :PF), do: List.delete(l, :SD), else: l)

    {:ok, MapSet.new(l)}
  end

  @spec mods(Enum.t()) :: {:ok, 0..2_147_483_647} | {:error, {:unknown_mod, atom}}
  def mods(l) do
    val =
      Enum.reduce_while(l, 0, fn m, acc ->
        case @mod_to_num[m] do
          nil -> {:halt, {:error, {:unknown_mod, m}}}
          n -> {:cont, acc + n}
        end
      end)

    if is_integer(val) do
      val =
      if Enum.member?(l, :NC) and not Enum.member?(l, :DT) do
        val + @mod_to_num[:DT]
      else
        val
      end

      val =
      if Enum.member?(l, :PF) and not Enum.member?(l, :SD) do
        val + @mod_to_num[:SD]
      else
        val
      end

      {:ok, val}
    else
      val
    end
  end
end
