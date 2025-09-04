defmodule Chatex.Session do
  use GenServer

  ##
  ## API
  ##

  def start_link(username) do
    GenServer.start_link(__MODULE__, username, name: via_global(username))
  end

  def send_message(username, room, message) do
    GenServer.cast(via_global(username), {:send_message, room, message})
  end

  def register_cli(username, cli_pid) do
    GenServer.cast(via_global(username), {:register_cli, cli_pid})
  end

  def pid(username), do: :global.whereis_name({:session, username})

  defp via_global(username), do: {:global, {:session, username}}

  ##
  ## Callbacks
  ##

  @impl true
  def init(username), do: {:ok, %{username: username, cli: nil}}

  @impl true
  def handle_cast({:register_cli, cli_pid}, state) do
    {:noreply, %{state | cli: cli_pid}}
  end

  @impl true
  def handle_cast({:send_message, room, msg}, state) do
    Chatex.Room.send_message(room, state.username, msg)
    {:noreply, state}
  end

  @impl true
  def handle_info({:new_message, %{user: user, text: text, room_name: room_name}}, state) do
    if user != state.username do
      IO.puts("[#{room_name}/#{user}]: #{text}")
    end

    {:noreply, state}
  end
end
