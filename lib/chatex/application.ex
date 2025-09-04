defmodule Chatex.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    {:ok, hostname} = :inet.gethostname()
    rand_suffix = :crypto.strong_rand_bytes(4) |> Base.encode16()
    node_name = :"chatex_#{rand_suffix}@#{hostname}.local"
    IO.puts("Starting node #{node_name}")

    Node.start(node_name)
    Node.set_cookie(:chatex)

    children = [
      Chatex.Node,
      {Chatex.RoomSupervisor, []}
      # Starts a worker by calling: Chatex.Worker.start_link(arg)
      # {Chatex.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Chatex.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
