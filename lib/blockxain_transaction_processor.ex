defmodule Blockxain.TransactionProcessor do
  alias Blockxain.TransactionsServer
  alias Blockxain.BlocksServer

  use Task

  def start_link(transactions_server_pid, server_pid) do
    Task.start_link(__MODULE__, :run, [transactions_server_pid, server_pid])
  end

  def run(transactions_server_pid, server_pid) do
    with transactions <- TransactionsServer.flush(transactions_server_pid) do
      process(server_pid, transactions)
      run(transactions_server_pid, server_pid)
    end
  end

  defp process(_, []), do: nil

  defp process(server_pid, transactions) when length(transactions) > 1 do
    IO.puts "process"
    BlocksServer.add_block(server_pid, transactions)
  end
end
