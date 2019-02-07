defmodule Bitset do
  @moduledoc """
  Documentation for Bitset.
  the fixed-size N bits
  """
  import Kernel, except: [to_string: 1]

  @set_bit 1
  @unset_bit 0

  @type t :: %__MODULE__{}

  defstruct size: 0, data: <<>>

  @spec new(bitstring() | non_neg_integer()) :: Bitset.t()
  def new(size) when is_integer(size) do
    %Bitset{size: size, data: <<@unset_bit::size(size)>>}
  end

  @spec new(bitstring(), integer()) :: Bitset.t()
  def new(<<data::bits>>, size) when is_integer(size) do
    %Bitset{size: size, data: data}
  end

  @spec size(Bitset.t()) :: integer()
  def size(bitset = %Bitset{}) do
    bitset.size
  end

  @spec size(bitstring()) :: integer()
  def size(<<data::bits>>) do
    bit_size(data)
  end

  @spec test?(Bitset.t(), integer()) :: boolean()
  def test?(bitset = %Bitset{}, pos) do
    at(bitset.data, pos) |> elem(2) == @set_bit
  end

  @spec all?(bitstring() | Bitset.t()) :: boolean()
  def all?(bitset = %Bitset{}), do: all?(bitset.data)
  def all?(<<1::1>>), do: true
  def all?(<<0::1>>), do: false
  def all?(<<1::1, rest::bits>>), do: all?(rest)
  def all?(<<0::1, _rest::bits>>), do: false

  @spec any?(bitstring() | Bitset.t()) :: boolean()
  def any?(bitset = %Bitset{}), do: any?(bitset.data)
  def any?(<<>>), do: false
  def any?(<<1::1, _rest::bits>>), do: true
  def any?(<<0::1, rest::bits>>), do: any?(rest)

  @spec none?(bitstring() | Bitset.t()) :: boolean()
  def none?(bitset = %Bitset{}), do: none?(bitset.data)
  def none?(<<>>), do: true
  def none?(<<1::1, _rest::bits>>), do: false
  def none?(<<0::1, rest::bits>>), do: none?(rest)

  @doc "the number of bits set to true"
  @spec count(Bitset.t()) :: integer
  def count(bitset = %Bitset{}) do
    for(<<bit::1 <- bitset.data>>, do: bit) |> Enum.sum()
  end

  @doc "sets all bits to true"
  @spec set(Bitset.t()) :: Bitset.t()
  def set(bitset = %Bitset{}) do
    size = bitset.size
    value = trunc(:math.pow(2, size)) - 1
    new(<<value::size(size)>>, size)
  end

  @doc "sets the bit at the position to bit value"
  @spec set(Bitset.t(), integer, integer) :: Bitset.t()
  def set(bitset = %Bitset{}, pos, bit \\ @set_bit) do
    data = set_bit(bitset.data, pos, bit)
    new(data, bitset.size)
  end

  @doc "sets all bits to false"
  @spec reset(Bitset.t()) :: Bitset.t()
  def reset(bitset = %Bitset{}) do
    size = bitset.size
    new(<<@unset_bit::size(size)>>, size)
  end

  @doc "sets the bit at the position to false"
  @spec reset(Bitset.t(), integer) :: Bitset.t()
  def reset(bitset = %Bitset{}, pos) do
    data = set_bit(bitset.data, pos, @unset_bit)
    new(data, bitset.size)
  end

  @doc "toggle all bits"
  @spec flip(Bitset.t()) :: Bitset.t()
  def flip(bitset = %Bitset{}) do
    new(flip_bit(bitset.data, <<>>), bitset.size)
  end

  @doc "toggle the bit at the position"
  @spec flip(Bitset.t(), integer) :: Bitset.t()
  def flip(bitset = %Bitset{}, pos) when is_integer(pos) do
    <<prefix::size(pos), val::1, rest::bits>> = bitset.data
    new(<<prefix::size(pos), :erlang.band(val + 1, 1)::1, rest::bits>>, bitset.size)
  end

  @spec reverse(Bitset.t()) :: Bitset.t()
  def reverse(bitset = %Bitset{}), do: new(reverse_bit(bitset.data, <<>>), bitset.size)

  @doc "return string representation of the bitset"
  @spec to_string(bitstring() | Bitset.t(), bitstring()) :: binary()
  def to_string(_, acc \\ <<>>)

  def to_string(bitset = %Bitset{}, acc) do
    to_string(bitset.data, acc)
  end

  def to_string(<<>>, acc), do: acc

  def to_string(<<1::1, rest::bits>>, acc) do
    to_string(rest, acc <> "1")
  end

  def to_string(<<0::1, rest::bits>>, acc) do
    to_string(rest, acc <> "0")
  end

  @doc "return Bitset data binary"
  @spec to_data(Bitset.t()) :: bitstring()
  def to_data(bitset = %Bitset{}) do
    bitset.data
  end

  @spec to_binary(Bitset.t()) :: bitstring()
  def to_binary(bitset = %Bitset{}) do
    reverse_byte(bitset.data, <<>>)
  end

  defp at(data, pos) do
    <<prefix::size(pos), bit::size(1), rest::bits>> = data
    {prefix, bit, rest}
  end

  defp set_bit(data, pos, bit) do
    <<prefix::size(pos), val::size(1), rest::bits>> = data

    if val != bit do
      <<prefix::size(pos), bit::size(1), rest::bits>>
    else
      data
    end
  end

  defp flip_bit(<<>>, acc), do: acc

  defp flip_bit(<<1::1, rest::bits>>, acc) do
    flip_bit(rest, <<acc::bits, 0::1>>)
  end

  defp flip_bit(<<0::1, rest::bits>>, acc) do
    flip_bit(rest, <<acc::bits, 1::1>>)
  end

  defp reverse_bit(<<>>, acc), do: acc

  defp reverse_bit(<<bit::1, rest::bits>>, acc) do
    reverse_bit(rest, <<bit::1, acc::bits>>)
  end

  defp reverse_byte(<<>>, acc), do: acc

  defp reverse_byte(<<bit::8, rest::bits>>, acc) do
    reverse_byte(rest, acc <> reverse_bit(<<bit::8>>, <<>>))
  end

  defp reverse_byte(<<rest::bits>>, acc) do
    padding = 8 - bit_size(rest)
    reverse_byte(<<rest::bits, 0::size(padding)>>, acc)
  end
end
