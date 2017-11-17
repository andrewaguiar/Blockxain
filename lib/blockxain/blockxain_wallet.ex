defmodule Blockxain.Wallet do
  require RsaEx

  defstruct [:public_key, :private_key]

  def create_new_wallet do
    with {:ok, {private_key, public_key}} <- RsaEx.generate_keypair("4096") do
      %Blockxain.Wallet{public_key: public_key, private_key: private_key}
    end
  end
end
