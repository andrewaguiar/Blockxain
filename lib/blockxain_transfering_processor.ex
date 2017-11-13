defmodule Blockxain.TransferingProcessor do
  alias Blockxain.TransferingServer
  alias Blockxain.BlocksServer

  use Task

  def start_link(transfering_server_pid, server_pid) do
    Task.start_link(__MODULE__, :run, [transfering_server_pid, server_pid])
  end

  def run(transfering_server_pid, server_pid) do
    with transferings <- TransferingServer.flush(transfering_server_pid) do
      process(server_pid, transferings)
      run(transfering_server_pid, server_pid)
    end
  end

  defp process(_, []), do: nil

  defp process(server_pid, transferings) when length(transferings) > 1 do
    BlocksServer.add_block(server_pid, transferings)
  end
end
