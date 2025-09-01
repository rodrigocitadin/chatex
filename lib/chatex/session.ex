defmodule Chatex.Session do
  use GenServer

  ##
  ## API
  ##

  def start_link(username) do
    GenServer.start_link(__MODULE__, username, name: via_tuple(username))
  end

  def send_message(username, room, message) do
    GenServer.cast(via_tuple(username), {:send_message, room, message})
  end

  def pid(username), do: GenServer.whereis({:via, Registry, {Chatex.SessionRegistry, username}})

  defp via_tuple(username), do: {:via, Registry, {Chatex.SessionRegistry, username}}

  ##
  ## Callbacks
  ##

  @impl true
  def init(username), do: {:ok, %{username: username}}

  @impl true
  def handle_cast({:send_message, room, msg}, state) do
    Chatex.Room.send_message(room, state.username, msg)
    {:noreply, state}
  end

  @impl true
  def handle_info({:new_message, %{user: user, text: text, room_name: room_name}}, state) do
    IO.puts("(#{room_name})/[#{user}]: #{text}")
    {:noreply, state}
  end
end
