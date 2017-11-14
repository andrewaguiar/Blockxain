defmodule Blockxain.WalletTest do
  use ExUnit.Case

  test "create a new wallet" do
    %Blockxain.Wallet{public_key: public_key, private_key: private_key} = Blockxain.Wallet.create_new_wallet

    assert String.length(public_key) >= 800
    assert String.length(private_key) >= 3243
  end
end
