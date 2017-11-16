defmodule Blockxain.TransactionsServer do
  use GenServer

  @max_pool_size 10

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def add(server, transaction) do
    GenServer.cast(server, {:add, transaction})
  end

  def flush(server) do
    GenServer.call(server, {:flush})
  end

  def info(server) do
    GenServer.call(server, {:info})
  end

  def init(:ok) do
    {:ok, []}
  end

  def handle_call({:info}, _from, transaction_list) do
    {:reply, {:ok, %{transaction_list_length: length(transaction_list)}}, transaction_list}
  end

  def handle_call({:flush}, _from, transaction_list) do
    if length(transaction_list) >= @max_pool_size do
      {:reply, transaction_list, []}
    else
      {:reply, [], transaction_list}
    end
  end

  def handle_cast({:add, transaction}, transaction_list) do
    {:noreply, transaction_list ++ [transaction]}
  end
end
