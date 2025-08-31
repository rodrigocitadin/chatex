defmodule Chatex.Session do
  use GenServer

  ##
  ## API
  ##

  def start_link(username) do
    GenServer.start_link(__MODULE__, username, name: via_tuple(username))
  end

  def send_message(username, message) do
    GenServer.cast(via_tuple(username), {:message, message})
  end

  def get_messages(username) do
    GenServer.call(via_tuple(username), :get_messages)
  end

  defp via_tuple(username), do: {:via, Registry, {Chatex.SessionRegistry, username}}

  ##
  ## Callbacks
  ##

  @impl true
  def init(username) do
    state = %{
      username: username,
      messages: []
    }

    {:ok, state}
  end

  @impl true
  def handle_cast({:message, msg}, state) do
    IO.puts("[#{state.username}] sent: #{msg}")

    new_state = %{state | messages: [msg | state.messages]}
    {:noreply, new_state}
  end

  @impl true
  def handle_call(:get_messages, _from, state) do
    {:reply, Enum.reverse(state.messages), state}
  end
end
