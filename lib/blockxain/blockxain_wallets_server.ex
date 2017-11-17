defmodule Blockxain.WalletsServer do
  @moduledoc """
  The wallets server, stores the state of wallets ledger, transactions and transactions
  by wallets.
  """
  use GenServer

  alias Blockxain.Crypto
  alias Blockxain.WalletsTransactionIOLedger

  ## Client API

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def add_transaction(server, transaction) do
    GenServer.cast(server, {:add_transaction, transaction})
  end

  def wallet_balance(server, %Blockxain.Wallet{public_key: public_key}) do
    GenServer.call(server, {:wallet_balance, public_key})
  end

  def wallet_transactions(server, %Blockxain.Wallet{public_key: public_key}) do
    GenServer.call(server, {:wallet_transactions, public_key})
  end

  def transactions(server) do
    GenServer.call(server, {:transactions})
  end

  def info(server) do
    GenServer.call(server, {:info})
  end

  ## Callbacks

  def init(:ok) do
    {:ok, %{
      wallets_ledger: %WalletsTransactionIOLedger{ledgers: %{}},
      transactions: [],
      wallet_transactions: %{}}}
  end

  def handle_cast({:add_transaction, transaction}, state) do
    {:noreply, add_transaction_to_state(state, transaction)}
  end

  def handle_call({:wallet_balance, wallet_public_key}, _from, state) do
    {:reply, {:ok, fetch_wallet_balance(state, wallet_public_key)}, state}
  end

  def handle_call({:wallet_transactions, wallet_public_key}, _from, state) do
    {:reply, {:ok, fetch_wallet_transactions(state, wallet_public_key)}, state}
  end

  def handle_call({:transactions}, _from, state) do
    {:reply, {:ok, state.transactions}, state}
  end

  def handle_call({:info}, _from, state) do
    {:reply, {:ok, fetch_info(state)}, state}
  end

  ## Functions

  defp add_transaction_to_state(state, transaction) do
    with wallet_from_hash <- generate_wallet_hash(transaction.from),
         wallet_to_hash <- generate_wallet_hash(transaction.to),
         # Initializes wallet register in ledger when it does not exist
         new_wallets_ledger <- initialize_wallets_if_not_exist(state.wallets_ledger,
                                                               wallet_from_hash,
                                                               wallet_to_hash),
         # yields the transaction and creates a new wallet ledger
         {:ok, new_wallets_ledger} <- WalletsTransactionIOLedger.yield_transaction(new_wallets_ledger,
                                                                                   transaction.hash,
                                                                                   wallet_from_hash,
                                                                                   wallet_to_hash,
                                                                                   transaction.amount),
         # registers the new transaction
         new_transactions <- state.transactions ++ [transaction],
         # registers the new transaction in both from to wallet
         new_wallet_transactions <- add_transaction_to_wallet_transactions(state.wallet_transactions,
                                                                           wallet_from_hash,
                                                                           wallet_to_hash,
                                                                           transaction) do
      # creates the new state
      %{wallets_ledger: new_wallets_ledger,
        transactions: new_transactions,
        wallet_transactions: new_wallet_transactions}
    end
  end

  defp fetch_wallet_balance(state, wallet_public_key) do
    with wallet_hash <- generate_wallet_hash(wallet_public_key) do
      WalletsTransactionIOLedger.wallet_balance(state.wallets_ledger, wallet_hash)
    end
  end

  def fetch_wallet_transactions(state, wallet_public_key) do
    with wallet_hash <- generate_wallet_hash(wallet_public_key) do
      Map.get(state.wallet_transactions, wallet_hash)
    end
  end

  def fetch_info(state) do
    %{wallets_length: (state.wallets_ledger.ledgers |> Map.keys |> length)}
  end

  defp add_transaction_to_wallet_transactions(wallet_transactions, wallet_from_hash, wallet_to_hash,  %Blockxain.Transaction{hash: tx_hash}) do
    wallet_transactions
    |> Map.update(wallet_from_hash, [tx_hash], &(&1 ++ [tx_hash]))
    |> Map.update(wallet_to_hash, [tx_hash], &(&1 ++ [tx_hash]))
  end

  defp initialize_wallets_if_not_exist(ledgers, wallet_from_hash, wallet_to_hash) do
    ledgers
    |> WalletsTransactionIOLedger.yield_genesis_transaction(wallet_from_hash)
    |> WalletsTransactionIOLedger.yield_genesis_transaction(wallet_to_hash)
  end

  defp generate_wallet_hash(wallet_public_key) do
    Crypto.hash(wallet_public_key)
  end
end
