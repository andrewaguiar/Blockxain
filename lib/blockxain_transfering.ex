defmodule Blockxain.Transfering do
  require RsaEx

  defstruct [:hash, :from, :to, :amount, :timestamp, :signature]

  def valid?(%Blockxain.Transfering{from: from, to: to, amount: amount, timestamp: timestamp, signature: signature}) do
    generate_data(from, to, amount, timestamp) |> RsaEx.verify(signature, from)
  end

  def transfer(%Blockxain.Wallet{public_key: public_key, private_key: private_key}, dest_public_key, amount) do
    with timestamp <- :os.system_time(:millisecond),
         data <- generate_data(public_key, dest_public_key, amount, timestamp),
         {:ok, signature} <- RsaEx.sign(data, private_key) do

      %Blockxain.Transfering{
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
    :crypto.hash(:sha256, "#{data}:#{signature}") |> Base.encode16
  end

  defp generate_data(from, to, amount, timestamp) do
    "#{from}:#{to}:#{amount}:#{timestamp}"
  end
end

