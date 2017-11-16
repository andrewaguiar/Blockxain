defmodule Blockxain.WalletsTransactionIOLedgerTest do
  use ExUnit.Case

  alias Blockxain.WalletsTransactionIOLedger

  test "wallet transaction io ledger flow" do
    w = %Blockxain.WalletsTransactionIOLedger{
      ledgers: %{
        "alice" => [
          %Blockxain.TransactionIOLedger.InOut{tx_hash: "tx0", amount: 50, origin_tx_hash: ["tx0"]}
        ],
        "bob" => []
      }
    }

    assert WalletsTransactionIOLedger.wallet_balance(w, "alice") == 50
    assert WalletsTransactionIOLedger.wallet_balance(w, "bob") == 0

    {:ok, w} = WalletsTransactionIOLedger.yield_transaction(w, "tx1", "alice", "bob", 30)

    assert WalletsTransactionIOLedger.wallet_balance(w, "alice") == 20
    assert WalletsTransactionIOLedger.wallet_balance(w, "bob") == 30

    {:ok, w} = WalletsTransactionIOLedger.yield_transaction(w, "tx2", "bob", "alice", 5)

    assert WalletsTransactionIOLedger.wallet_balance(w, "alice") == 25
    assert WalletsTransactionIOLedger.wallet_balance(w, "bob") == 25

    # Trying to perform a transaction without balance results in error
    {:error, :not_enough_balance} = WalletsTransactionIOLedger.yield_transaction(w, "tx3", "bob", "alice", 26)

    assert w == %Blockxain.WalletsTransactionIOLedger{
      ledgers: %{
        "alice" => [
          %Blockxain.TransactionIOLedger.InOut{amount: 50, origin_tx_hash: ["tx0"], tx_hash: "tx0"},
          %Blockxain.TransactionIOLedger.InOut{amount: -50, origin_tx_hash: ["tx0"], tx_hash: "tx1"},
          %Blockxain.TransactionIOLedger.InOut{amount: 20, origin_tx_hash: ["tx0"], tx_hash: "tx1"},
          %Blockxain.TransactionIOLedger.InOut{amount: 5, origin_tx_hash: ["tx1"], tx_hash: "tx2"}
        ],
        "bob" => [
          %Blockxain.TransactionIOLedger.InOut{amount: 30, origin_tx_hash: ["tx0"], tx_hash: "tx1"},
          %Blockxain.TransactionIOLedger.InOut{amount: -30, origin_tx_hash: ["tx1"], tx_hash: "tx2"},
          %Blockxain.TransactionIOLedger.InOut{amount: 25, origin_tx_hash: ["tx1"], tx_hash: "tx2"}
        ]
      }
    }
  end
end
