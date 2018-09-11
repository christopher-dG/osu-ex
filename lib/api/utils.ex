defmodule OsuEx.API.Utils do
  @moduledoc "Utility functions for handling enum values and mods."

  use Bitwise, only_operators: true

  @doc """
  Translates the game mode enum to an atom and vice versa.

  ## Examples

      iex> OsuEx.API.Utils.mode(0)
      :standard

      iex> OsuEx.API.Utils.mode(:taiko)
      1
  """
  def mode(_m)

  @spec mode(0..3) :: atom
  def mode(0), do: :standard
  def mode(1), do: :taiko
  def mode(2), do: :catch
  def mode(3), do: :mania

  @spec mode(atom) :: 0..3
  def mode(:standard), do: 0
  def mode(:taiko), do: 1
  def mode(:catch), do: 2
  def mode(:mania), do: 3

  @doc """
  Translates the approved status enum to an atom and vice versa.

  ## Examples

      iex> OsuEx.API.Utils.approved(-2)
      :graveyard

      iex> OsuEx.API.Utils.approved(:wip)
      -1
  """
  def approved(_a)

  @spec approved(-2..4) :: atom
  def approved(-2), do: :graveyard
  def approved(-1), do: :wip
  def approved(0), do: :pending
  def approved(1), do: :ranked
  def approved(2), do: :approved
  def approved(3), do: :qualified
  def approved(4), do: :loved

  @spec approved(atom) :: -2..4
  def approved(:graveyard), do: -2
  def approved(:wip), do: -1
  def approved(:pending), do: 0
  def approved(:ranked), do: 1
  def approved(:approved), do: 2
  def approved(:qualified), do: 3
  def approved(:loved), do: 4

  @doc """
  Translates the genre enum to an atom and vice versa.

  ## Examples

      iex> OsuEx.API.Utils.genre(0)
      :any

      iex> OsuEx.API.Utils.genre(:unspecified)
      1
  """
  def genre(_g)

  @spec genre(0..10) :: atom
  def genre(0), do: :any
  def genre(1), do: :unspecified
  def genre(2), do: :video_game
  def genre(3), do: :anime
  def genre(4), do: :rock
  def genre(5), do: :pop
  def genre(6), do: :other
  def genre(7), do: :novelty
  def genre(9), do: :hip_hop
  def genre(10), do: :electronic

  @spec genre(atom) :: 0..10
  def genre(:any), do: 0
  def genre(:unspecified), do: 1
  def genre(:video_game), do: 2
  def genre(:anime), do: 3
  def genre(:rock), do: 4
  def genre(:pop), do: 5
  def genre(:other), do: 6
  def genre(:novelty), do: 7
  def genre(:hip_hop), do: 9
  def genre(:electronic), do: 10

  @doc """
  Translates the language enum to an atom and vice versa.

  ## Examples

      iex> OsuEx.API.Utils.language(0)
      :any

      iex> OsuEx.API.Utils.language(:other)
      1
  """
  def language(_l)

  @spec language(0..11) :: atom
  def language(0), do: :any
  def language(1), do: :other
  def language(2), do: :english
  def language(3), do: :japanese
  def language(4), do: :chinese
  def language(5), do: :instrumental
  def language(6), do: :korean
  def language(7), do: :french
  def language(8), do: :german
  def language(9), do: :swedish
  def language(10), do: :spanish
  def language(11), do: :italian

  @spec language(atom) :: 0..11
  def language(:any), do: 0
  def language(:other), do: 1
  def language(:english), do: 2
  def language(:japanese), do: 3
  def language(:chinese), do: 4
  def language(:instrumental), do: 5
  def language(:korean), do: 6
  def language(:french), do: 7
  def language(:german), do: 8
  def language(:swedish), do: 9
  def language(:spanish), do: 10
  def language(:italian), do: 11

  @doc """
  Translates the scoring type enum to an atom and vice versa.

  ## Examples

      iex> OsuEx.API.Utils.scoring_type(0)
      :score

      iex> OsuEx.API.Utils.scoring_type(:accuracy)
      1
  """
  def scoring_type(_s)

  @spec scoring_type(0..3) :: atom
  def scoring_type(0), do: :score
  def scoring_type(1), do: :accuracy
  def scoring_type(2), do: :combo
  def scoring_type(3), do: :score_v2

  @spec scoring_type(atom) :: 0..3
  def scoring_type(:score), do: 0
  def scoring_type(:accuracy), do: 1
  def scoring_type(:combo), do: 2
  def scoring_type(:score_v2), do: 3

  @doc """
  Translates the team type enum to an atom and vice versa.

  ## Examples

      iex> OsuEx.API.Utils.team_type(0)
      :head_to_head

      iex> OsuEx.API.Utils.team_type(:tag_coop)
      1
  """
  def team_type(_t)

  @spec team_type(0..3) :: atom
  def team_type(0), do: :head_to_head
  def team_type(1), do: :tag_coop
  def team_type(2), do: :team_vs
  def team_type(3), do: :tag_team_vs

  @spec team_type(atom) :: 0..3
  def team_type(:head_to_head), do: 0
  def team_type(:tag_coop), do: 1
  def team_type(:team_vs), do: 2
  def team_type(:tag_team_vs), do: 3

  @doc """
  Translates the team enum to an atom and vice versa.

  ## Examples

      iex> OsuEx.API.Utils.team(1)
      :blue

      iex> OsuEx.API.Utils.team(:red)
      2
  """
  def team(_t)

  @spec team(1..2) :: atom
  def team(1), do: :blue
  def team(2), do: :red

  @spec team(atom) :: 1..2
  def team(:blue), do: 1
  def team(:red), do: 2

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
  @max_mod 2_147_483_647

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
  def mods(n) when is_integer(n) and n >= 0 and n <= @max_mod do
    l =
      Enum.reduce(@mod_to_num, [], fn {m, i}, acc ->
        if((i &&& n) === i, do: acc ++ [m], else: acc)
      end)

    l = if(Enum.member?(l, :NC), do: List.delete(l, :DT), else: l)
    l = if(Enum.member?(l, :PF), do: List.delete(l, :SD), else: l)

    {:ok, MapSet.new(l)}
  end

  @spec mods(Enum.t()) :: {:ok, 0..2_147_483_647} | {:error, {:unknown_mod, atom}}
  def mods(l) when not is_integer(l) do
    val =
      Enum.reduce_while(l, 0, fn m, acc ->
        case @mod_to_num[m] do
          nil -> {:halt, {:error, {:unknown_mod, m}}}
          n -> {:cont, acc + n}
        end
      end)

    case val do
      n when is_integer(n) ->
        n =
          if Enum.member?(l, :NC) and not Enum.member?(l, :DT) do
            n + @mod_to_num[:DT]
          else
            n
          end

        n =
          if Enum.member?(l, :PF) and not Enum.member?(l, :SD) do
            n + @mod_to_num[:SD]
          else
            n
          end

        {:ok, n}

      _ ->
        val
    end
  end
end
