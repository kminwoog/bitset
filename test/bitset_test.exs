defmodule BitsetTest do
  use ExUnit.Case
  doctest Bitset

  import Bitset
  import Kernel, except: [to_string: 1]

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

  test "bitset - to_string" do
    assert new(10) |> set(0) |> to_string() == "0000000100"
    assert new(10) |> set(1) |> to_string() == "0000001000"
    # assert new(10) |> set(9) |> to_string() == "0000001000"
    assert new(3) |> set(0) |> set(1) |> set(2) |> to_string() == "111"
  end
end
