defmodule Blockxain.MainServer do
  use GenServer

  alias Blockxain.TransferingServer
  alias Blockxain.BlocksServer
  alias Blockxain.TransferingProcessor
  alias Blockxain.WalletsServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def info(server) do
    GenServer.call(server, {:info})
  end

  def wallet_balance(server, wallet) do
    GenServer.call(server, {:wallet_balance, wallet})
  end

  def wallet_transactions(server, wallet) do
    GenServer.call(server, {:wallet_transactions, wallet})
  end

  def add_transfering(server, transfering) do
    GenServer.cast(server, {:add_transfering, transfering})
  end

  def init(:ok) do
    with {:ok, transfering_server_pid} <- TransferingServer.start_link,
         {:ok, blocks_server_pid} <- BlocksServer.start_link,
         {:ok, transfering_task_pid} <- TransferingProcessor.start_link(transfering_server_pid, blocks_server_pid),
         {:ok, wallets_server_pid} <- WalletsServer.start_link do

      {:ok, %{transfering_server_pid: transfering_server_pid,
              blocks_server_pid: blocks_server_pid,
              transfering_task_pid: transfering_task_pid,
              wallets_server_pid: wallets_server_pid}}
    end
  end

  def handle_call({:info}, _from, pids) do
    with {:ok, transfering_server_info} <- TransferingServer.info(pids.transfering_server_pid),
         {:ok, blocks_server_info} <- BlocksServer.info(pids.blocks_server_pid),
         {:ok, wallets_server_info} <- WalletsServer.info(pids.wallets_server_pid) do

      {:reply, Map.merge(Map.merge(transfering_server_info, blocks_server_info), wallets_server_info), pids}
    end
  end

  def handle_call({:wallet_balance, wallet}, _from, pids) do
    {:reply, WalletsServer.wallet_balance(pids.wallets_server_pid, wallet), pids}
  end

  def handle_call({:wallet_transactions, wallet}, _from, pids) do
    {:reply, WalletsServer.wallet_transactions(pids.wallets_server_pid, wallet), pids}
  end

  def handle_cast({:add_transfering, transfering}, pids) do
    with {:ok, true} <- Blockxain.Transfering.valid?(transfering),
         :ok <- WalletsServer.add_transfering(pids.wallets_server_pid, transfering),
         :ok <- TransferingServer.add(pids.transfering_server_pid, transfering) do
      {:noreply, pids}
    end
  end
end
