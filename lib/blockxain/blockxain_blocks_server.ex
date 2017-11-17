defmodule Blockxain.BlocksServer do
  require Logger

  use GenServer

  @doc """
  Starts the registry.
  """
  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def add_block(server, transactions) do
    GenServer.cast(server, {:add_block, Blockxain.generate_data(transactions)})
  end

  def info(server) do
    GenServer.call(server, {:info})
  end

  def init(:ok) do
    {:ok, Blockxain.genesis()}
  end

  def handle_call({:info}, _from, blockchain) do
    {:reply, {:ok, %{blockchain_length: length(blockchain)}}, blockchain}
  end

  def handle_cast({:add_block, data}, blockchain) do
    with new_blockchain <- Blockxain.add(blockchain, data),
         [recently_added_block | _] <- new_blockchain,
         _ <- Logger.info("[BlocksServer] adding a block in blockchain #{recently_added_block.hash}") do

      {:noreply, new_blockchain}
    end
  end
end
