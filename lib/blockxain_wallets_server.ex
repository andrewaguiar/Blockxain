defmodule Blockxain.WalletsServer do
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def add_transfering(server, %Blockxain.Transfering{hash: hash, from: from, to: to, amount: amount}) do
    GenServer.cast(server, {:add_transfering, hash, from, to, amount})
  end

  def wallet_balance(server, %Blockxain.Wallet{public_key: public_key}) do
    GenServer.call(server, {:wallet_balance, public_key})
  end

  def wallet_transactions(server, %Blockxain.Wallet{public_key: public_key}) do
    GenServer.call(server, {:wallet_transactions, public_key})
  end

  def info(server) do
    GenServer.call(server, {:info})
  end

  def show(server) do
    GenServer.call(server, {:show})
  end

  def init(:ok) do
    {:ok, %{}}
  end

  def handle_cast({:add_transfering, hash, from, to, amount}, wallets) do
    with wallet_from_hash <- generate_wallet_hash(from),
         wallet_from_record <- [{hash, -amount}],
         wallet_to_hash <- generate_wallet_hash(to),
         wallet_to_record <- [{hash, amount}],
         new_wallet <- update_from_to_wallets(wallets, wallet_from_hash, wallet_from_record, wallet_to_hash, wallet_to_record) do

      {:noreply, new_wallet}
    end
  end

  def handle_call({:wallet_balance, wallet_public_key}, _from, wallets) do
    with records <- wallet_records(wallet_public_key, wallets),
         {_, balance} <- Enum.reduce(records, fn {_, x}, {_, t} -> {nil, x + t} end) do
      {:reply, {:ok, balance}, wallets}
    end
  end

  def handle_call({:wallet_transactions, wallet_public_key}, _from, wallets) do
    {:reply, {:ok, wallet_records(wallet_public_key, wallets)}, wallets}
  end

  def handle_call({:info}, _from, wallets) do
    {:reply, {:ok, %{wallets_length: length(Map.keys(wallets))}}, wallets}
  end

  def handle_call({:show}, _from, wallets) do
    {:reply, {:ok, wallets}, wallets}
  end

  defp wallet_records(wallet_public_key, wallets) do
    with wallet_hash <- generate_wallet_hash(wallet_public_key),
         %{^wallet_hash => wallet_records} = wallets do
      wallet_records
    end
  end

  defp update_from_to_wallets(wallets, wallet_from_hash, wallet_from_record, wallet_to_hash, wallet_to_record) do
    wallets
    |> Map.update(wallet_from_hash, wallet_from_record, &(&1 ++ wallet_from_record))
    |> Map.update(wallet_to_hash, wallet_to_record, &(&1 ++ wallet_to_record))
  end

  defp generate_wallet_hash(wallet_public_key) do
    :crypto.hash(:sha256, wallet_public_key) |> Base.encode16
  end
end
