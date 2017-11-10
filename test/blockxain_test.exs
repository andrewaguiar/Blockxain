defmodule Blockxain.BlockTest do
  use ExUnit.Case

  test "genesis block creation" do
    with b0 <- Blockxain.Block.genesis("first block") do
      assert b0.index == 0
      assert Regex.match?(~r/[0-9a-fA-F]+/, b0.hash)
      assert b0.data == "first block"
      assert b0.previous_hash == "0"
      assert Regex.match?(~r/[0-9a-fA-F]+/, b0.difficult)
      assert b0.timestamp > 0
      assert b0.nonce > 0
    end
  end

  test "next block creation" do
    with b0 <- Blockxain.Block.genesis("first block"),
         b1 <- Blockxain.Block.next(b0, "second block") do
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
end
