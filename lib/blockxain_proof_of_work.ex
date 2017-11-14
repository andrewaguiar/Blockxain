defmodule Blockxain.ProofOfWork do
  @moduledoc """
  Implements a Proof of Work algorithm
  """

  def valid?(data, nonce, hash, difficult) do
    with proof_hash <- generate_hash(nonce, data),
         {valid_given_difficut, _} <- validate_hash(proof_hash, difficult) do
      valid_given_difficut && (proof_hash == hash)
    else
      _ -> false
    end
  end

  @doc """
  Given a data and a difficult (beginning of the hash), computes hashs with an increment
  till we get a hash starting with difficult, then returns the number of tries and the hash

  ## Examples
      iex> Blockxain.ProofOfWork.compute_hash_with_proof_of_work("Our data here", "ABC")
      {4181, "ABC44B5C8AF4ECC3E4B90F2B712C7B5FDF3A918FDE8B555EEAC38611D8AC7C5A"}
  """
  def compute_hash_with_proof_of_work(data, difficult) do
    compute_hash_with_proof_of_work_with_nonce(data, difficult, 0)
  end

  defp compute_hash_with_proof_of_work_with_nonce(data, difficult, nonce) do
    with hash <- generate_hash(nonce, data),
         {true, hash} <- validate_hash(hash, difficult) do
      {nonce, hash}
    else
      _ -> compute_hash_with_proof_of_work_with_nonce(data, difficult, nonce + 1)
    end
  end

  defp validate_hash(hash, difficult) do
    {String.starts_with?(hash, difficult), hash}
  end

  defp generate_hash(nonce, data) do
    :crypto.hash(:sha256, "#{nonce}-#{data}") |> Base.encode16
  end
end
