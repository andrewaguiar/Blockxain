defmodule Blockxain.TransactionIOLedger do
  defmodule InOut do
    defstruct [:tx_hash, :amount, :origin_tx_hash]
  end

  def find_possible_inputs_to_create_an_output(ios, amount) do
    case(find_input_exactly(ios, amount) || find_input_bigger(ios, amount) || find_inputs_smaller_till_complete(ios, amount)) do
      xs when is_list(xs) -> xs
      x -> [x]
    end
  end

  defp find_input_exactly(ios, amount) do
    Enum.find(ios, &(&1.amount == amount))
  end

  defp find_input_bigger(ios, amount) do
    Enum.find(ios, &(&1.amount > amount))
  end

  defp find_inputs_smaller_till_complete(ios, amount) do
    ios
    |> Enum.reject(&(&1.amount < 0))
    |> Enum.sort(&(&1.amount >= &2.amount))
    |> Enum.reduce_while([], &(if sum_ios(&2) < amount, do: {:cont, &2 ++ [&1]}, else: {:halt, &2}))
  end

  def sum_ios(ios) do
    ios
    |> Enum.map(&(&1.amount))
    |> Enum.sum
  end
end
