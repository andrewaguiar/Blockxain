defmodule Blockxain.MainServer do
  use GenServer

  require Logger

  alias Blockxain.Transaction
  alias Blockxain.TransactionsServer
  alias Blockxain.BlocksServer
  alias Blockxain.TransactionProcessor
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

  def add_transaction(server, transaction) do
    GenServer.cast(server, {:add_transaction, transaction})
  end

  def init(:ok) do
    with {:ok, transaction_server_pid} <- TransactionsServer.start_link,
         _ <- Logger.info("[MainServer] started TransactionsServer"),
         {:ok, blocks_server_pid} <- BlocksServer.start_link,
         _ <- Logger.info("[MainServer] started BlocksServer"),
         {:ok, transaction_task_pid} <- TransactionProcessor.start_link(transaction_server_pid, blocks_server_pid),
         _ <- Logger.info("[MainServer] started TransactionProcessor"),
         {:ok, wallets_server_pid} <- WalletsServer.start_link,
         _ <- Logger.info("[MainServer] started WalletsServer") do

      {:ok, %{transaction_server_pid: transaction_server_pid,
              blocks_server_pid: blocks_server_pid,
              transaction_task_pid: transaction_task_pid,
              wallets_server_pid: wallets_server_pid}}
    end
  end

  def handle_call({:info}, _from, pids) do
    with {:ok, transaction_server_info} <- TransactionsServer.info(pids.transaction_server_pid),
         {:ok, blocks_server_info} <- BlocksServer.info(pids.blocks_server_pid),
         {:ok, wallets_server_info} <- WalletsServer.info(pids.wallets_server_pid) do

      {:reply, Map.merge(Map.merge(transaction_server_info, blocks_server_info), wallets_server_info), pids}
    end
  end

  def handle_call({:wallet_balance, wallet}, _from, pids) do
    {:reply, WalletsServer.wallet_balance(pids.wallets_server_pid, wallet), pids}
  end

  def handle_cast({:add_transaction, transaction}, pids) do
    with {:ok, true} <- Transaction.valid?(transaction),
         :ok <- WalletsServer.add_transaction(pids.wallets_server_pid, transaction),
         :ok <- TransactionsServer.add(pids.transaction_server_pid, transaction),
         _ <- Logger.info("[MainServer] add_transaction #{transaction.hash}") do
      {:noreply, pids}
    end
  end
end
