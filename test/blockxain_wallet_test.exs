defmodule Blockxain.WalletTest do
  use ExUnit.Case

  test "create a new wallet" do
    with w0 <- Blockxain.Wallet.create_new_wallet do
      assert String.length(w0.public_key) >= 800
      assert String.length(w0.private_key) >= 3243
    end
  end
end
