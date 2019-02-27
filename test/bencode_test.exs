defmodule BencodeTest do
  use ExUnit.Case
  doctest Bencode

  describe "Bencode.decode" do
    test "decodes integers" do
      assert Bencode.decode("i10e") == {:ok, 10}
      assert Bencode.decode("i-10e") == {:ok, -10}
      assert Bencode.decode("i0e") == {:ok, 0}
    end

    test "decodes strings" do
      assert Bencode.decode("0:") == {:ok, ""}
      assert Bencode.decode("5:hello") == {:ok, "hello"}
    end

    test "decodes lists" do
      assert Bencode.decode("le") == {:ok, []}
      assert Bencode.decode("l2:js7:haskelli21ee") == {:ok, ["js", "haskell", 21]}
    end

    test "decodes dictionaries" do
      assert Bencode.decode("de") == {:ok, %{}}
      assert Bencode.decode("d4:name4:kanae") == {:ok, %{"name" => "kana"}}
    end

    test "fails if not eof" do
      assert Bencode.decode("i1ei2e") == {:error, :not_eof}
    end

    test "fails on invalid terms" do
      assert Bencode.decode("ie") == {:error, %{rest: "ie"}}
      assert Bencode.decode("d4:namee") == {:error, %{rest: "4:namee"}}
    end

    test "decodes complex example" do
      encoded = "d4:name4:kana3:agei21e5:langsl2:js7:haskellee"
      decoded = %{"name" => "kana", "age" => 21, "langs" => ["js", "haskell"]}
      assert Bencode.decode(encoded) == {:ok, decoded}
    end
  end
end
