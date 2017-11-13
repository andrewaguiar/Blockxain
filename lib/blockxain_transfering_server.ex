defmodule Blockxain.TransferingServer do
  use GenServer

  @max_pool_size 10

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def add(server, transfering) do
    with {:ok, true} <- Blockxain.Transfering.valid?(transfering),
         {:ok, true} <- {:ok, true} do # should check wallet_balance_valid?(transfering)
      GenServer.cast(server, {:add, transfering})
    else
      _ -> {:error}
    end
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

  def handle_call({:info}, _from, transfering_list) do
    {:reply, {:ok, %{transfering_list_length: length(transfering_list)}}, transfering_list}
  end

  def handle_call({:flush}, _from, transfering_list) do
    case length(transfering_list) do
      x when x >= @max_pool_size ->
        {:reply, transfering_list, []}
      _ ->
        {:reply, [], transfering_list}
    end
  end

  def handle_cast({:add, transfering}, transfering_list) do
    {:noreply, transfering_list ++ [transfering]}
  end
end
