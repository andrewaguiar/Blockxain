defmodule Blockxain.MerkleTree do
  defstruct [:hash, :children]

  defmodule Leaf do
    defstruct [:hash]
  end

  defmodule Gallow do
    defstruct [:hash, :children]
  end

  def build_merkle_tree(values) do
    values
    |> Enum.map(fn value -> %Leaf{hash: generate_hash(value)} end)
    |> build_gallows
  end

  defp build_gallows([%{hash: hash, children: children}]) do
    %Blockxain.MerkleTree{hash: hash, children: children}
  end

  defp build_gallows(values) do
    values
    |> Enum.chunk_every(2)
    |> Enum.map(fn tuple -> concatenate(tuple) end)
    |> build_gallows
  end

  defp concatenate([%{hash: hash_a}, %{hash: hash_b}] = tuple) do
    %Gallow{hash: generate_hash(hash_a <> hash_b), children: tuple}
  end

  defp concatenate([%{hash: hash_a}] = tuple) do
    %Gallow{hash: generate_hash(hash_a <> hash_a), children: tuple}
  end

  defp generate_hash(data) do
    :crypto.hash(:sha256, "#{data}") |> Base.encode16
  end
end
