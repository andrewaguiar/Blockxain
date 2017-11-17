defmodule Blockxain.MerkleTree do
  @moduledoc """
  Implements the merkle tree algorithm https://en.wikipedia.org/wiki/Merkle_tree
  """

  alias Blockxain.Crypto

  defstruct [:hash, :children]

  def create(values) do
    values
    |> create_leaves
    |> create_gallows
  end

  defp create_leaves(values) do
    values
    |> Enum.map(fn value -> %{hash: generate_hash(value)} end)
  end

  defp create_gallows([%{hash: hash, children: children}]) do
    %Blockxain.MerkleTree{hash: hash, children: children}
  end

  defp create_gallows(values) do
    values
    |> Enum.chunk_every(2)
    |> Enum.map(fn tuple -> concatenate(tuple) end)
    |> create_gallows
  end

  defp concatenate([%{hash: hash_a}, %{hash: hash_b}] = tuple) do
    # H(A) | H(B)
    %{hash: generate_hash(hash_a <> hash_b), children: tuple}
  end

  defp concatenate([%{hash: hash_a}] = tuple) do
    # in case of odd number of children, just replicate it
    # H(A) | H(A)
    %{hash: generate_hash(hash_a <> hash_a), children: tuple}
  end

  defp generate_hash(data) do
    Crypto.hash(data)
  end
end
