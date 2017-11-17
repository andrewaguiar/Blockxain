defmodule Blockxain.Crypto do
  @moduledoc """
  Groups all crypto and hashs functions used across the project
  """

  def hash(data) do
    :sha256 |> :crypto.hash(data) |> Base.encode16
  end
end
