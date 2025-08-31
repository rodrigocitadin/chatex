defmodule Chatex.Room do
  use GenServer

  ##
  ## API  
  ##

  def start_link(name) do
    GenServer.start_link(__MODULE__, %{}, name: via_tuple(name))
  end

  def join(room_name, username, session_pid) do
    GenServer.call(via_tuple(room_name), {:join, username, session_pid})
  end

  def send_message(room_name, from, message) do
    GenServer.cast(via_tuple(room_name), {:message, from, message})
  end

  defp via_tuple(room_name), do: {:via, Registry, {Chatex.RoomRegistry, room_name}}

  ##
  ## Callbacks
  ##

  def init(_) do
    {:ok, %{sessions: %{}}}
  end

  def handle_call({:join, username, session_pid}, _from, state) do
    new_state = put_in(state, [:sessions, username], session_pid)
    {:reply, :ok, new_state}
  end

  def handle_cast({:message, from, message}, state) do
    Enum.each(state.sessions, fn {_username, pid} ->
      send(pid, {:new_message, from, message})
    end)

    {:noreply, state}
  end
end
