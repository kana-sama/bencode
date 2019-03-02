defmodule BencodeTest do
  use ExUnit.Case
  doctest Bencode

  describe "Bencode.parse" do
    test "parses integers" do
      assert Bencode.parse("i10e") == {:ok, 10}
      assert Bencode.parse("i-10e") == {:ok, -10}
      assert Bencode.parse("i0e") == {:ok, 0}
    end

    test "parses strings" do
      assert Bencode.parse("0:") == {:ok, ""}
      assert Bencode.parse("5:hello") == {:ok, "hello"}
    end

    test "parses lists" do
      assert Bencode.parse("le") == {:ok, []}
      assert Bencode.parse("l2:js7:haskelli21ee") == {:ok, ["js", "haskell", 21]}
    end

    test "parses dictionaries" do
      assert Bencode.parse("de") == {:ok, %{}}
      assert Bencode.parse("d4:name4:kanae") == {:ok, %{"name" => "kana"}}
    end

    test "fails if not eof" do
      assert Bencode.parse("i1ei2e") == {:error, :not_eof}
    end

    test "fails on invalid terms" do
      assert Bencode.parse("ie") == {:error, %{rest: "ie"}}
      assert Bencode.parse("d4:namee") == {:error, %{rest: "4:namee"}}
    end

    test "parses complex example" do
      encoded = "d4:name4:kana3:agei21e5:langsl2:js7:haskellee"
      parsed = %{"name" => "kana", "age" => 21, "langs" => ["js", "haskell"]}
      assert Bencode.parse(encoded) == {:ok, parsed}
    end
  end
end
