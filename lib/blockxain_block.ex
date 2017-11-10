defmodule Blockxain.Block do
  defstruct [:index, :timestamp, :data, :previous_hash, :nonce, :difficult, :hash]

  @doc """
  Creates a genesis block, the beginning of the blockchain
  """
  def genesis(data) do
    create_block(0, data, "0")
  end

  @doc """
  Creates a block and appends it in the end of the block chain
  """
  def next(%Blockxain.Block{index: previous_block_index, hash: previous_block_hash}, data) do
    create_block(previous_block_index + 1, data, previous_block_hash)
  end

  defp create_block(index, data, previous_hash) do
    with timestamp <- :os.system_time(:millisecond),
          consolidated_data <- consolidate_data(index, timestamp, previous_hash, data),
          difficult <- generate_difficult(),
          {nonce, hash} <- Blockxain.ProofOfWork.compute_hash_with_proof_of_work(consolidated_data, difficult) do

      %Blockxain.Block{
        index: index,
        timestamp: timestamp,
        data: data,
        previous_hash: previous_hash,
        nonce: nonce,
        difficult: difficult,
        hash: hash
      }
    else
      _ -> {:error}
    end
  end

  defp generate_difficult do
    :rand.uniform(99999999999) |> Integer.to_string(16) |> String.slice(1..4)
  end

  defp consolidate_data(index, timestamp, previous_hash, data) do
    "#{index}#{timestamp}#{previous_hash}#{data}"
  end
end
