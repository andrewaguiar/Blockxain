defmodule Blockxain.WalletsServerTest do
  use ExUnit.Case

  alias Blockxain.Wallet
  alias Blockxain.Transfering
  alias Blockxain.WalletsServer

  setup do
    with {:ok, server_pid} = WalletsServer.start_link() do
      {:ok, server: server_pid}
    end
  end

  test "add, info and flush", %{server: server_pid} do
    w1 = Wallet.create_new_wallet
    w2 = Wallet.create_new_wallet

    t1 = Transfering.transfer(w1, w2.public_key, 5)
    t2 = Transfering.transfer(w1, w2.public_key, 6)

    WalletsServer.add_transfering(server_pid, t1)
    WalletsServer.add_transfering(server_pid, t2)

    assert WalletsServer.wallet_balance(server_pid, w1) == {:ok, -11}

    {:ok, transactions_w1} = WalletsServer.wallet_transactions(server_pid, w1)
    assert length(transactions_w1) == 2

    assert WalletsServer.wallet_balance(server_pid, w2) == {:ok, 11}

    {:ok, transactions_w2} = WalletsServer.wallet_transactions(server_pid, w2)
    assert length(transactions_w2) == 2

    assert WalletsServer.info(server_pid) == {:ok, %{wallets_length: 2}}
  end
end
