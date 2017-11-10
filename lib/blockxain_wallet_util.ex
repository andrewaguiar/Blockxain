defmodule Blockxain.WalletUtil do
  def persist_in_file(file, %Blockxain.Wallet{} = wallet) do
    File.write(file, :erlang.term_to_binary(wallet))
  end

  def load_from_file(file) do
    with {:ok, content} <- File.read(file) do
      :erlang.binary_to_term(content)
    end
  end
end
