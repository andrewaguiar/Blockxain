defmodule Blockxain.Transfering do
  require RsaEx

  defstruct [:from, :to, :amount, :signature]

  def valid?(%Blockxain.Transfering{from: from, to: to, amount: amount, signature: signature}) do
    with data <- "#{from}:#{to}:#{amount}" do
      RsaEx.verify(data, signature, from)
    end
  end

  def transfer(%Blockxain.Wallet{public_key: public_key, private_key: private_key}, dest_public_key, amount) do
    with data <- "#{public_key}:#{dest_public_key}:#{amount}",
         {:ok, signature} <- RsaEx.sign(data, private_key) do
      %Blockxain.Transfering{from: public_key, to: dest_public_key, amount: amount, signature: signature}
    end
  end
end

