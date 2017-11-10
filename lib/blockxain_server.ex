defmodule Blockxain.Server do
  use GenServer

  @doc """
  Starts the registry.
  """
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def add(server, data) do
    GenServer.cast(server, {:add, data})
  end

  def get(server) do
    GenServer.call(server, {:get})
  end

  def init(:ok) do
    {:ok, Blockxain.genesis()}
  end

  def handle_call({:get}, _from, blockchain) do
    {:reply, blockchain, blockchain}
  end

  def handle_cast({:add, data}, blockchain) do
    {:noreply, Blockxain.add(blockchain, data)}
  end
end
