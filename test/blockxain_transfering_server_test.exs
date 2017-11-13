defmodule Blockxain.TransferingServerTest do
  use ExUnit.Case

  alias Blockxain.TransferingServer
  alias Blockxain.Transfering
  alias Blockxain.Wallet

  setup do
    with {:ok, server_pid} = TransferingServer.start_link do
      {:ok, server: server_pid}
    end
  end

  test "add, info and flush", %{server: server_pid} do
    assert TransferingServer.info(server_pid) == {:ok, %{transfering_list_length: 0}}

    w1 = Wallet.create_new_wallet
    w2 = Wallet.create_new_wallet

    TransferingServer.add(server_pid, Transfering.transfer(w1, w2.public_key, 42))
    TransferingServer.add(server_pid, Transfering.transfer(w1, w2.public_key, 42))
    TransferingServer.add(server_pid, Transfering.transfer(w1, w2.public_key, 42))
    TransferingServer.add(server_pid, Transfering.transfer(w1, w2.public_key, 42))
    TransferingServer.add(server_pid, Transfering.transfer(w1, w2.public_key, 42))
    TransferingServer.add(server_pid, Transfering.transfer(w1, w2.public_key, 42))
    TransferingServer.add(server_pid, Transfering.transfer(w1, w2.public_key, 42))
    TransferingServer.add(server_pid, Transfering.transfer(w1, w2.public_key, 42))
    TransferingServer.add(server_pid, Transfering.transfer(w1, w2.public_key, 42))

    assert TransferingServer.info(server_pid) == {:ok, %{transfering_list_length: 9}}

    # Flush should work only when 10 > elements
    assert TransferingServer.flush(server_pid) == []

    TransferingServer.add(server_pid, Transfering.transfer(w1, w2.public_key, 42))

    assert length(TransferingServer.flush(server_pid)) == 10

    assert TransferingServer.info(server_pid) == {:ok, %{transfering_list_length: 0}}
  end
end
