defmodule Chatex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    name = :"chatex_#{:crypto.strong_rand_bytes(4) |> Base.encode16()}"
    {:ok, _} = :net_kernel.start([name, :shortnames])
    Node.set_cookie(:chatex)
    IO.puts("Starting node #{Node.self()}")

    children = [
      Chatex.Node,
      {Chatex.RoomSupervisor, []}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chatex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
