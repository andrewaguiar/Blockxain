defmodule Blockxain.TransactionTest do
  use ExUnit.Case

  alias Blockxain.Transaction
  alias Blockxain.Wallet

  test "creating and validating a transaction" do
    w_origin = Wallet.create_new_wallet
    w_dest = Wallet.create_new_wallet

    transaction = Transaction.create(w_origin, w_dest.public_key, 120)

    %Transaction{
      hash: hash,
      from: from,
      to: to,
      amount: amount,
      timestamp: timestamp,
      signature: signature
    } = transaction

    assert Regex.match?(~r/[0-9a-fA-F]+/, hash)
    assert String.length(from) >= 800
    assert String.length(to) >= 800
    assert amount == 120
    assert timestamp > 0
    assert byte_size(signature) > 0

    assert Transaction.valid?(transaction)
  end
end
