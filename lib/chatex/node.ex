defmodule Chatex.Node do
  use GenServer

  def start_link(_), do: GenServer.start_link(__MODULE__, nil, name: __MODULE__)

  def init(_) do
    schedule_connect()
    {:ok, nil}
  end

  def handle_info(:connect, state) do
    case :net_adm.names() do
      {:ok, names} ->
        nodes =
          Enum.map(names, fn {name, _port} ->
            :"#{name}@arch.local"
          end)

        Enum.each(nodes, fn n ->
          if n != Node.self(), do: Node.connect(n)
        end)

      _ ->
        IO.puts("I couldn't get the list of nodes from epmd")
    end

    schedule_connect()
    {:noreply, state}
  end

  defp schedule_connect(), do: Process.send_after(self(), :connect, 5_000)
end
