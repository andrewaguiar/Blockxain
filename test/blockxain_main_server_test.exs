defmodule Blockxain.MainServerTest do
  use ExUnit.Case

  alias Blockxain.MainServer
  alias Blockxain.Transaction
  alias Blockxain.Wallet

  setup do
    with {:ok, server_pid} = MainServer.start_link do
      {:ok, server: server_pid}
    end
  end

  test "add, info and flush", %{server: server_pid} do
    assert MainServer.info(server_pid) == %{blockchain_length: 1, transaction_list_length: 0, wallets_length: 0}

    w1 = Wallet.create_new_wallet
    w2 = Wallet.create_new_wallet

    MainServer.add_transaction(server_pid, Transaction.create(w1, w2.public_key, 100))

    assert MainServer.wallet_balance(server_pid, w1) == {:ok, 900}
    assert MainServer.wallet_balance(server_pid, w2) == {:ok, 1100}

    MainServer.add_transaction(server_pid, Transaction.create(w1, w2.public_key, 100))

    assert MainServer.wallet_balance(server_pid, w1) == {:ok, 800}
    assert MainServer.wallet_balance(server_pid, w2) == {:ok, 1200}

    MainServer.add_transaction(server_pid, Transaction.create(w1, w2.public_key, 100))

    assert MainServer.wallet_balance(server_pid, w1) == {:ok, 700}
    assert MainServer.wallet_balance(server_pid, w2) == {:ok, 1300}

    MainServer.add_transaction(server_pid, Transaction.create(w2, w1.public_key, 50))

    assert MainServer.wallet_balance(server_pid, w1) == {:ok, 750}
    assert MainServer.wallet_balance(server_pid, w2) == {:ok, 1250}

    MainServer.add_transaction(server_pid, Transaction.create(w2, w1.public_key, 250))

    assert MainServer.wallet_balance(server_pid, w1) == {:ok, 1000}
    assert MainServer.wallet_balance(server_pid, w2) == {:ok, 1000}


    assert MainServer.info(server_pid) == %{blockchain_length: 1, transaction_list_length: 5, wallets_length: 2}

    MainServer.add_transaction(server_pid, Transaction.create(w2, w1.public_key, 3))
    MainServer.add_transaction(server_pid, Transaction.create(w2, w1.public_key, 3))
    MainServer.add_transaction(server_pid, Transaction.create(w2, w1.public_key, 3))
    MainServer.add_transaction(server_pid, Transaction.create(w2, w1.public_key, 3))
    MainServer.add_transaction(server_pid, Transaction.create(w2, w1.public_key, 3))

    assert MainServer.wallet_balance(server_pid, w1) == {:ok, 1015}
    assert MainServer.wallet_balance(server_pid, w2) == {:ok, 985}

    :timer.sleep(500)

    assert MainServer.info(server_pid) == %{blockchain_length: 2, transaction_list_length: 0, wallets_length: 2}
  end
end
