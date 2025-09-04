defmodule Chatex.CLI do
  def start do
    username = ask_username()
    IO.puts("Welcome to Chatex, #{username}!")
    loop(%{room: nil, user: username})
  end

  defp ask_username do
    username = IO.gets("Choose your username: ") |> String.trim()

    case :global.register_name({:session, username}, self()) do
      :yes ->
        username

      :no ->
        IO.puts("Username '#{username}' already taken. Try another")
        ask_username()
    end
  end

  defp loop(state) do
    input = IO.gets("> ") |> String.trim()

    cond do
      input == "/exit" ->
        :global.unregister_name({:session, state.user})
        IO.puts("Bye!")
        :ok

      String.starts_with?(input, "/join ") ->
        room = String.replace_prefix(input, "/join ", "")

        case Chatex.Room.join(room, state.user) do
          :ok ->
            IO.puts("Joined room '#{room}'")
            loop(%{state | room: room})

          _ ->
            IO.puts("Failed to join room")
            loop(state)
        end

      input == "/leave" ->
        if state.room do
          Chatex.Room.leave(state.room, state.user)
          IO.puts("Left room '#{state.room}'")
        end

        loop(%{state | room: nil})

      state.room != nil and input != "" ->
        Chatex.Room.send_message(state.user, state.room, input)
        loop(state)

      input != "" ->
        IO.puts("Not in a room. Use /join <room> first.")
        loop(state)

      true ->
        loop(state)
    end
  end
end
