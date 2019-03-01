# bitset
[![Hex.pm Version](https://img.shields.io/hexpm/v/bitset.svg)](https://hex.pm/packages/bitset)
 
elixir bitset module inspired by stl bitset, C# BitArray

  
## Installation
add in deps of `mix.exs`
```elixir
def deps do
  [
    {:bitset, "~> 0.2"}
  ]
end
```

## Test

```elixir
test "bitset - new" do
    assert new(0) == %Bitset{size: 0, data: <<>>}
    assert new(10) == %Bitset{size: 10, data: <<0, 0::2>>}
    assert new(17) == %Bitset{size: 17, data: <<0, 0, 0::1>>}
  end

  test "bitset - all?" do
    assert not (new(10) |> set(0) |> all?())
    assert not (new(10) |> set(1) |> all?())
    assert not (new(10) |> set(9) |> all?())
    assert new(3) |> set(0) |> set(1) |> set(2) |> all?()
  end

  test "bitset - any?" do
    assert new(10) |> set(0) |> any?()
    assert new(10) |> set(1) |> any?()
    assert new(10) |> set(9) |> any?()
    assert new(3) |> set(0) |> set(1) |> set(2) |> any?()
  end

  test "bitset - none?" do
    assert not (new(10) |> set(0) |> none?())
    assert not (new(10) |> set(1) |> none?())
    assert not (new(10) |> set(9) |> none?())
    assert not (new(3) |> set(0) |> set(1) |> set(2) |> none?())

    assert new(1) |> none?()
    assert new(5) |> none?()
    assert new(8) |> none?()
    assert new(10) |> none?()
  end

  # 10110000
  defp bit8() do
    new(8) |> set(0) |> set(2) |> set(3)
  end

  # 10110000 10
  defp bit10() do
    new(10) |> set(0) |> set(2) |> set(3) |> set(8)
  end

  # 10110000 11010100 00010001 00001010
  defp bit32() do
    new(32)
    |> set(0)
    |> set(2)
    |> set(3)
    |> set(8)
    |> set(9)
    |> set(11)
    |> set(13)
    |> set(19)
    |> set(23)
    |> set(28)
    |> set(30)
  end

  # 10110000 11010100 00010001 00001010 101
  defp bit35() do
    new(35)
    |> set(0)
    |> set(2)
    |> set(3)
    |> set(8)
    |> set(9)
    |> set(11)
    |> set(13)
    |> set(19)
    |> set(23)
    |> set(28)
    |> set(30)
    |> set(32)
    |> set(34)
  end

  test "bitset - flip" do
    # 10110000 10
    # flip> 01001111 01
    assert bit10() |> to_string() == "1011000010"
    assert bit10() |> flip() |> to_string() == "0100111101"

    # 10110000 10
    assert bit10() |> flip(2) |> to_string() == "1001000010"
    # 10110000 10
    assert bit10() |> flip(8) |> to_string() == "1011000000"
  end

  test "bitset - reverse" do
    # 10110000 10
    # reverse> 01001111 01
    assert bit10() |> to_string() == "1011000010"
    assert bit10() |> reverse() |> to_string() == "0100001101"
  end

  test "bitset - set all bits" do
    assert new(1) |> set() |> count() == 1
    assert new(8) |> set(1) |> set() |> count() == 8
    assert new(11) |> set() |> count() == 11
    assert new(19) |> set() |> count() == 19
  end

  test "bitset - reset" do
    assert bit10() |> reset() |> count() == 0
    assert bit32() |> reset() |> count() == 0
    assert bit35() |> reset() |> count() == 0
    assert new(8) |> set(1) |> reset(1) |> count() == 0
  end

  test "bitset - to_string" do
    assert new(10) |> set(0) |> to_string() == "1000000000"
    assert new(10) |> set(1) |> to_string() == "0100000000"
    # assert new(10) |> set(9) |> to_string() == "0000001000"
    assert new(3) |> set(0) |> set(1) |> set(2) |> to_string() == "111"

    # 10110000 10
    # 10110000 11010100 00010001 00001010
    # 10110000 11010100 00010001 00001010 101
    assert bit10() |> to_string() == "1011000010"

    assert bit32()
           |> to_string() ==
             "10110000110101000001000100001010"

    assert bit35()
           |> to_string() ==
             "10110000110101000001000100001010101"
  end

  test "bitset - to_binary" do
    # 10110000
    # -> 00001101
    assert bit8() |> to_binary() |> to_string() == "00001101"

    # 10110000 10
    # -> 00001101 00000001
    assert bit10() |> to_binary() |> size() == 16
    assert bit10() |> to_binary() |> to_string() == "0000110100000001"

    # 10110000 11010100 00010001 00001010
    # -> 00001101 00101011 10001000 01010000
    assert bit32()
           |> to_binary()
           |> to_string() ==
             "00001101001010111000100001010000"

    # 10110000 11010100 00010001 00001010 101
    # -> 00001101 00101011 10001000 01010000 00000101
    assert bit35()
           |> to_binary()
           |> to_string() ==
             "0000110100101011100010000101000000000101"
  end
```
