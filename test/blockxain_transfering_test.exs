defmodule Blockxain.TransferingTest do
  use ExUnit.Case

  alias Blockxain.Transfering
  alias Blockxain.Wallet

  test "creating and validating a transfering" do
    w_origin = Wallet.create_new_wallet
    w_dest = Wallet.create_new_wallet

    transfering = Transfering.transfer(w_origin, w_dest.public_key, 120)

    %Transfering{
      hash: hash,
      from: from,
      to: to,
      amount: amount,
      timestamp: timestamp,
      signature: signature
    } = transfering

    assert Regex.match?(~r/[0-9a-fA-F]+/, hash)
    assert String.length(from) >= 800
    assert String.length(to) >= 800
    assert amount == 120
    assert timestamp > 0
    assert byte_size(signature) > 0

    assert Transfering.valid?(transfering)
  end
end
