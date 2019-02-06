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

  @spec test?(Bitset.t(), integer()) :: boolean()
  def test?(bitset = %Bitset{}, pos) do
    at(bitset, pos) |> elem(2) == @set_bit
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
  def count(bitset = %Bitset{}) do
    for(<<bit::1 <- bitset.data>>, do: bit) |> Enum.sum()
  end

  @doc "sets all bits to true"
  def set(bitset = %Bitset{}) do
    size = bitset.size
    value = :math.pow(2, size)
    new(<<value::size(size)>>, size)
  end

  @doc "sets the bit at the position to true"
  def set(bitset = %Bitset{}, pos) do
    set_bit(bitset, pos, @set_bit)
  end

  @doc "sets all bits to false"
  def reset(bitset = %Bitset{}) do
    size = bitset.size
    new(<<@unset_bit::size(size)>>, size)
  end

  @doc "sets the bit at the position to false"
  def reset(bitset = %Bitset{}, pos) do
    set_bit(bitset, pos, @unset_bit)
  end

  @doc "toggle all bits"
  def flip(bitset = %Bitset{}) do
    flip_bit(bitset.data, <<>>)
  end

  @doc "toggle the bit at the position"
  def flip(bitset = %Bitset{}, pos) when is_integer(pos) do
    {bytes, offset} = offset(bitset, pos)
    <<prefix::size(bytes), padding::size(offset), val::1, rest::bits>> = bitset.data

    new(
      <<prefix::size(bytes), padding::size(offset), :erlang.band(val + 1, 1)::size(1),
        rest::bits>>,
      bitset.size
    )
  end

  @spec reverse(Bitset.t()) :: bitstring()
  def reverse(bitset = %Bitset{}), do: reverse_bit(bitset.data, <<>>)

  @doc "return string representation of the bitset"
  @spec to_string(Bitset.t()) :: bitstring()
  def to_string(bitset = %Bitset{}) do
    to_string(bitset.data, <<>>)
  end

  defp to_string(<<>>, acc), do: acc

  defp to_string(<<1::1, rest::bits>>, acc) do
    to_string(rest, acc <> "1")
  end

  defp to_string(<<0::1, rest::bits>>, acc) do
    to_string(rest, acc <> "0")
  end

  defp offset(bitset, pos) do
    bytes = trunc(pos / 8) * 8
    offset = min(8, bitset.size - bytes) - rem(pos, 8) - 1
    {bytes, offset}
  end

  defp at(bitset, pos) do
    {bytes, offset} = offset(bitset, pos)
    <<prefix::size(bytes), padding::size(offset), bit::size(1), rest::bits>> = bitset.data
    {prefix, padding, bit, rest}
  end

  defp set_bit(bitset, pos, bit) do
    {bytes, offset} = offset(bitset, pos)
    <<prefix::size(bytes), padding::size(offset), val::size(1), rest::bits>> = bitset.data

    if val != bit do
      new(<<prefix::size(bytes), padding::size(offset), bit::size(1), rest::bits>>, bitset.size)
    else
      bitset
    end
  end

  defp flip_bit(<<>>, acc), do: reverse(acc)

  defp flip_bit(<<1::1, rest::bits>>, acc) do
    flip(rest, <<0::1, acc::bits>>)
  end

  defp flip_bit(<<0::1, rest::bits>>, acc) do
    flip(rest, <<1::1, acc::bits>>)
  end

  defp reverse_bit(<<>>, acc), do: acc

  defp reverse_bit(<<bit::1, rest::bits>>, acc) do
    reverse_bit(rest, <<bit::1, acc::bits>>)
  end
end
