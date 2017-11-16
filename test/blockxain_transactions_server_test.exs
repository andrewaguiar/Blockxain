defmodule Blockxain.TransactionsServerTest do
  use ExUnit.Case

  alias Blockxain.TransactionsServer
  alias Blockxain.Transaction
  alias Blockxain.Wallet

  setup do
    with {:ok, server_pid} = TransactionsServer.start_link do
      {:ok, server: server_pid}
    end
  end

  test "add, info and flush", %{server: server_pid} do
    assert TransactionsServer.info(server_pid) == {:ok, %{transaction_list_length: 0}}

    w1 = Wallet.create_new_wallet
    w2 = Wallet.create_new_wallet

    TransactionsServer.add(server_pid, Transaction.create(w1, w2.public_key, 42))
    TransactionsServer.add(server_pid, Transaction.create(w1, w2.public_key, 42))
    TransactionsServer.add(server_pid, Transaction.create(w1, w2.public_key, 42))
    TransactionsServer.add(server_pid, Transaction.create(w1, w2.public_key, 42))
    TransactionsServer.add(server_pid, Transaction.create(w1, w2.public_key, 42))
    TransactionsServer.add(server_pid, Transaction.create(w1, w2.public_key, 42))
    TransactionsServer.add(server_pid, Transaction.create(w1, w2.public_key, 42))
    TransactionsServer.add(server_pid, Transaction.create(w1, w2.public_key, 42))
    TransactionsServer.add(server_pid, Transaction.create(w1, w2.public_key, 42))

    assert TransactionsServer.info(server_pid) == {:ok, %{transaction_list_length: 9}}

    # Flush should work only when 10 > elements
    assert TransactionsServer.flush(server_pid) == []

    TransactionsServer.add(server_pid, Transaction.create(w1, w2.public_key, 42))

    assert length(TransactionsServer.flush(server_pid)) == 10

    assert TransactionsServer.info(server_pid) == {:ok, %{transaction_list_length: 0}}
  end
end
