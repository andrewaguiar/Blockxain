defmodule Blockxain.Crypto do
  def hash(data) do
    :sha256 |> :crypto.hash(data) |> Base.encode16
  end
end
