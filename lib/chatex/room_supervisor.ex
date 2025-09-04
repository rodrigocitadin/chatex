defmodule Chatex.RoomSupervisor do
  use DynamicSupervisor

  def start_link(_) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  @impl true
  def init(:ok), do: DynamicSupervisor.init(strategy: :one_for_one)

  def start_room(room_name) do
    spec = {Chatex.Room, room_name}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
