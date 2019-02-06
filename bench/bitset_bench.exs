defmodule BitsetBench do
  use Benchfella

  # import Bitset

  bench "bitset to_string" do
    Bitset.new(10000) |> Bit2Str.to_string()
  end

  bench "bitset to_string2" do
    Bitset.new(10000) |> Bit2Str.to_string2()
  end

  bench "bitset to_string3" do
    Bitset.new(10000) |> Bit2Str.to_string3()
  end
end

defmodule Bit2Str do
  def to_string(bitset = %Bitset{}) do
    to_string(bitset.data, <<>>)
  end

  def to_string2(bitset = %Bitset{}) do
    to_string2(bitset.data, <<>>)
  end

  def to_string3(bitset = %Bitset{}) do
    to_string3(bitset.data, <<>>)
  end

  defp to_string(<<>>, acc), do: acc

  defp to_string(<<1::1, rest::bits>>, acc) do
    to_string(rest, acc <> "1")
  end

  defp to_string(<<0::1, rest::bits>>, acc) do
    to_string(rest, acc <> "0")
  end

  defp to_string2(<<>>, acc), do: String.reverse(acc)

  defp to_string2(<<1::1, rest::bits>>, acc) do
    to_string2(rest, "1" <> acc)
  end

  defp to_string2(<<0::1, rest::bits>>, acc) do
    to_string2(rest, "0" <> acc)
  end

  defp to_string3(<<>>, acc), do: String.reverse(:erlang.list_to_binary(acc))

  defp to_string3(<<1::1, rest::bits>>, acc) do
    to_string3(rest, ["1" | acc])
  end

  defp to_string3(<<0::1, rest::bits>>, acc) do
    to_string3(rest, ["0" | acc])
  end
end
