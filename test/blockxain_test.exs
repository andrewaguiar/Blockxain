defmodule BlockxainTest do
  use ExUnit.Case

  test "genesis block creation" do
    with [b0] <- Blockxain.genesis() do
      assert b0.index == 0
      assert Regex.match?(~r/[0-9a-fA-F]+/, b0.hash)
      assert b0.data == "genesis block"
      assert b0.previous_hash == "0"
      assert Regex.match?(~r/[0-9a-fA-F]+/, b0.difficult)
      assert b0.timestamp > 0
      assert b0.nonce > 0
    end
  end

  test "next block creation in sequence" do
    blockchain = Blockxain.genesis()
    |> Blockxain.add("data 1")
    |> Blockxain.add("data 2")
    |> Blockxain.add("data 3")
    |> Blockxain.add("data 4")
    |> Blockxain.add("data 5")
    |> Blockxain.add("data 6")
    |> Blockxain.add("data 7")
    |> Blockxain.add("data 8")

    assert length(blockchain) == 9
    assert Blockxain.valid?(blockchain) == true

    # Lets try to corrupt any block
    blockchain_corrupted = List.update_at(blockchain, 4, &(Map.put(&1, :data, "corruped")))

    assert blockchain_corrupted != blockchain
    assert Blockxain.valid?(blockchain_corrupted) == false
  end
end
