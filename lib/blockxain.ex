defmodule Blockxain do
  alias Blockxain.MerkleTree
  alias Blockxain.Block

  def genesis do
    [Block.genesis("genesis block")]
  end

  def add([last_block | _] = blockchain, data) do
    [Block.next(last_block, data)] ++ blockchain
  end

  def valid?([second_block, genesis_block]) do
    Block.valid?(second_block) && Block.valid?(genesis_block) && second_block.previous_hash == genesis_block.hash
  end

  def valid?([last_block | rest]) do
    with [prior_last_block | _] <- rest do
      Block.valid?(last_block) && (last_block.previous_hash == prior_last_block.hash) && valid?(rest)
    end
  end

  def generate_data(transactions) do
    with hashes <- Enum.map(transactions, fn transaction -> transaction.hash end),
         %MerkleTree{hash: merkle_tree_root_hash} <- MerkleTree.create(hashes) do
      "#{merkle_tree_root_hash}:#{Enum.join(hashes, ";")}"
    end
  end
end
