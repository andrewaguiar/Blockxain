defmodule Blockxain.Transaction do
  @moduledoc """
  Defines functions and a struct to deal with the transaction process, transaction is
  an abstraction of transfering values from a wallet to another
  """
  require RsaEx

  alias Blockxain.Crypto

  defstruct [:hash, :from, :to, :amount, :timestamp, :signature]

  def valid?(%Blockxain.Transaction{from: from, to: to, amount: amount, timestamp: timestamp, signature: signature}) do
    with data <- generate_data(from, to, amount, timestamp) do
      RsaEx.verify(data, signature, from)
    end
  end

  def create(%Blockxain.Wallet{public_key: public_key, private_key: private_key}, dest_public_key, amount) do
    with timestamp <- :os.system_time(:millisecond),
         data <- generate_data(public_key, dest_public_key, amount, timestamp),
         {:ok, signature} <- RsaEx.sign(data, private_key) do

      %Blockxain.Transaction{
        hash: generate_hash(data, signature),
        from: public_key,
        to: dest_public_key,
        amount: amount,
        timestamp: timestamp,
        signature: signature
      }
    end
  end

  defp generate_hash(data, signature) do
    Crypto.hash("#{data}:#{signature}")
  end

  defp generate_data(from, to, amount, timestamp) do
    "#{from}:#{to}:#{amount}:#{timestamp}"
  end
end
