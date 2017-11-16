defmodule Blockxain.WalletsTransactionIOLedger do
  alias Blockxain.TransactionIOLedger

  defstruct [:ledgers]

  def yield_transaction(%Blockxain.WalletsTransactionIOLedger{ledgers: ledgers}, transaction_hash, wallet_from_hash, wallet_to_hash, amount) do
    with wallet_from <- Map.get(ledgers, wallet_from_hash) do
      if TransactionIOLedger.sum_ios(wallet_from) >= amount do
        wallet_from
        |> TransactionIOLedger.find_possible_inputs_to_create_an_output(amount)
        |> mount_delta(transaction_hash, wallet_from_hash, wallet_to_hash, amount)
        |> apply_changes(ledgers, wallet_from_hash, wallet_to_hash)
        |> remount_ledger
      else
        {:error, :not_enough_balance}
      end
    end
  end

  def wallet_balance(%Blockxain.WalletsTransactionIOLedger{ledgers: ledgers}, wallet_hash) do
    TransactionIOLedger.sum_ios(Map.get(ledgers, wallet_hash))
  end

  def yield_genesis_transaction(%Blockxain.WalletsTransactionIOLedger{ledgers: ledgers}, wallet_hash) do
    %Blockxain.WalletsTransactionIOLedger{
      ledgers: Map.put_new(ledgers, wallet_hash, [%TransactionIOLedger.InOut{amount: 1000, origin_tx_hash: [], tx_hash: "0"}])
    }
  end

  defp remount_ledger(ledgers) do
    {:ok, %Blockxain.WalletsTransactionIOLedger{ledgers: ledgers}}
  end

  defp apply_changes(delta, ledgers, wallet_from_hash, wallet_to_hash) do
    ledgers
    |> Map.put(wallet_from_hash, Map.get(ledgers, wallet_from_hash) ++ Map.get(delta, wallet_from_hash))
    |> Map.put(wallet_to_hash, Map.get(ledgers, wallet_to_hash) ++ Map.get(delta, wallet_to_hash))
  end

  defp mount_delta(ios, transaction_hash, wallet_from_hash, wallet_to_hash, amount) do
    %{wallet_from_hash => mount_outputs(ios, transaction_hash) ++ mount_change_input(ios, transaction_hash, amount),
      wallet_to_hash => mount_inputs(ios, transaction_hash, amount)}
  end

  defp mount_outputs(ios, transaction_hash) do
    ios
    |> Enum.map(fn io ->
      %TransactionIOLedger.InOut{
        amount: -io.amount,
        origin_tx_hash: (if is_list(io.tx_hash), do: io.tx_hash, else: [io.tx_hash]),
        tx_hash: transaction_hash
      }
    end)
  end

  defp mount_change_input(ios, transaction_hash, amount) do
    with ios_sum <- TransactionIOLedger.sum_ios(ios) do
      if ios_sum > amount do
        [%TransactionIOLedger.InOut{tx_hash: transaction_hash,
                                    amount: ios_sum - amount,
                                    origin_tx_hash: Enum.map(ios, &(&1.tx_hash))}]
      else
        []
      end
    end
  end

  def mount_inputs(ios, transaction_hash, amount) do
    [%TransactionIOLedger.InOut{tx_hash: transaction_hash,
                               amount: amount,
                               origin_tx_hash: Enum.map(ios, &(&1.tx_hash))}]
  end
end
