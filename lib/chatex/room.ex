defmodule Chatex.Room do
  use GenServer

  ##
  ## API  
  ##

  def start_link(room_name) do
    GenServer.start_link(
      __MODULE__,
      %{name: room_name, messages: [], sessions: []},
      name: via_tuple(room_name)
    )
  end

  def join(room_name, username) do
    session_pid = Chatex.Session.pid(username)
    GenServer.call(via_tuple(room_name), {:join, session_pid})
  end

  def leave(room_name, username) do
    session_pid = Chatex.Session.pid(username)
    GenServer.call(via_tuple(room_name), {:leave, session_pid})
  end

  def send_message(room_name, username, message) do
    GenServer.cast(via_tuple(room_name), {:send_message, username, message})
  end

  def get_messages(room_name) do
    GenServer.call(via_tuple(room_name), :get_messages)
  end

  defp via_tuple(room_name), do: {:via, Registry, {Chatex.RoomRegistry, room_name}}

  ##
  ## Callbacks
  ##

  @impl true
  def init(state), do: {:ok, state}

  @impl true
  def handle_call({:join, session_pid}, _from, state) do
    {:reply, :ok, %{state | sessions: [session_pid | state.sessions]}}
  end

  @impl true
  def handle_call({:leave, session_pid}, _from, state) do
    {:reply, :ok, %{state | sessions: List.delete(state.sessions, session_pid)}}
  end

  @impl true
  def handle_call(:get_messages, _from, state) do
    {:reply, Enum.reverse(state.messages), state}
  end

  @impl true
  def handle_cast({:send_message, username, message}, state) do
    msg = %{user: username, text: message, ts: DateTime.utc_now()}
    new_state = %{state | messages: [msg | state.messages]}

    Enum.each(state.sessions, fn username ->
      send(username, {:new_message, Map.put(msg, :room_name, state.name)})
    end)

    {:noreply, new_state}
  end
end
