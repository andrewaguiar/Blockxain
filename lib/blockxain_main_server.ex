defmodule Blockxain.MainServer do
  use GenServer

  alias Blockxain.TransferingServer
  alias Blockxain.BlocksServer
  alias Blockxain.TransferingProcessor
  alias Blockxain.WalletsServer

  def start do
    start_link([])
  end

  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def info(server) do
    GenServer.call(server, {:info})
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

  def handle_cast({:add_transfering, transfering}, pids) do
    TransferingServer.add(pids.transfering_server_pid, transfering)
    WalletsServer.add_transfering(pids.wallets_server_pid, transfering)

    {:noreply, pids}
  end
end
