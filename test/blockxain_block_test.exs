defmodule Blockxain.BlockTest do
  use ExUnit.Case

  alias Blockxain.Block

  test "genesis block creation" do
    %Blockxain.Block{
      index: index,
      timestamp: timestamp,
      data: data,
      previous_hash: previous_hash,
      nonce: nonce,
      difficult: difficult,
      hash: hash
    } = Block.genesis("first block")

    assert index == 0
    assert Regex.match?(~r/[0-9a-fA-F]+/, hash)
    assert data == "first block"
    assert previous_hash == "0"
    assert Regex.match?(~r/[0-9a-fA-F]+/, difficult)
    assert timestamp > 0
    assert nonce > 0
  end

  test "next block creation" do
    with b0 <- Block.genesis("first block"),
         b1 <- Block.next(b0, "second block") do
      assert b1.index == 1
      assert Regex.match?(~r/[0-9a-fA-F]+/, b1.hash)
      assert b1.data == "second block"
      assert b1.previous_hash == b0.hash
      assert Regex.match?(~r/[0-9a-fA-F]+/, b1.difficult)
      assert b1.timestamp > 0
      assert b1.timestamp > b0.timestamp
      assert b1.nonce > 0
    end
  end

  test "block is valid" do
    with b0 <- Block.genesis("first block"),
         b1 <- Block.next(b0, "second block") do

      assert Block.valid?(b1) == true

      b1_corrupted = Map.put(b1, :data, "first block evil")

      assert Block.valid?(b1_corrupted) == false
    end
  end
end
