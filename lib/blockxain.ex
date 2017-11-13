defmodule Blockxain do
  alias Blockxain.MerkleTree

  def genesis do
    [Blockxain.Block.genesis("genesis block")]
  end

  def add([last_block | _] = blockchain, data) do
    [Blockxain.Block.next(last_block, data)] ++ blockchain
  end

  def generate_data(transferings) do
    with hashes <- Enum.map(transferings, fn transfering -> transfering.hash end),
         %Blockxain.MerkleTree{hash: merkle_tree_root_hash} <- MerkleTree.build_merkle_tree(hashes) do
      "#{merkle_tree_root_hash}:#{Enum.join(hashes, ",")}"
    end
  end
end
