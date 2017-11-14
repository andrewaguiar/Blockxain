defmodule Blockxain.MainServerTest do
  use ExUnit.Case

  alias Blockxain.MainServer
  alias Blockxain.Transfering
  alias Blockxain.Wallet

  setup do
    with {:ok, server_pid} = MainServer.start_link do
      {:ok, server: server_pid}
    end
  end

  test "add, info and flush", %{server: server_pid} do
    assert MainServer.info(server_pid) == %{blockchain_length: 1,
                                            transfering_list_length: 0,
                                            wallets_length: 0}

    w1 = Wallet.create_new_wallet
    w2 = Wallet.create_new_wallet

    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))
    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))
    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))
    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))
    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))
    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))
    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))
    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))
    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))
    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))
    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))
    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))
    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))
    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))
    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))
    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))
    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))
    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))
    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))
    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))
    MainServer.add_transfering(server_pid, Transfering.transfer(w1, w2.public_key, 10))

    assert MainServer.wallet_balance(server_pid, w1) == {:ok, -210}
    assert MainServer.wallet_balance(server_pid, w2) == {:ok, 210}

    {:ok, transactions_w1} = MainServer.wallet_transactions(server_pid, w1)
    assert length(transactions_w1) == 21

    {:ok, transactions_w2} = MainServer.wallet_transactions(server_pid, w2)
    assert length(transactions_w2) == 21

    assert MainServer.info(server_pid) == %{blockchain_length: 3,
                                            transfering_list_length: 1,
                                            wallets_length: 2}

  end
end
