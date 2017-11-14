defmodule Blockxain.BlocksServer do
  use GenServer

  @doc """
  Starts the registry.
  """
  def start_link() do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def add_block(server, transferings) do
    GenServer.cast(server, {:add_block, Blockxain.generate_data(transferings)})
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
    {:noreply, Blockxain.add(blockchain, data)}
  end
end
