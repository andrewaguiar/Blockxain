defmodule Blockxain do
  @moduledoc """
  Documentation for Blockxain
  """

  def genesis() do
    [Blockxain.Block.genesis("genesis block")]
  end

  def add([last_block | _] = blockchain, data) do
    [Blockxain.Block.next(last_block, data)] ++ blockchain
  end
end
