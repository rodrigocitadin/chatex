defmodule Chatex.CLI do
  def start do
    username = ask_username()
    IO.puts("Welcome to Chatex, #{username}!")
    {:ok, _pid} = Chatex.Session.start_link(username)
    spawn(fn -> input_loop(username, nil) end)
    listen_loop()
  end

  defp ask_username do
    username = IO.gets("Choose your username: ") |> String.trim()

    case :global.whereis_name({:session, username}) do
      :undefined ->
        username

      _ ->
        IO.puts("Username '#{username}' already taken. Try another")
        ask_username()
    end
  end

  defp input_loop(username, room) do
    input = IO.gets("[#{room}/#{username}]> ") |> String.trim()

    cond do
      input == "/exit" ->
        :global.unregister_name({:session, username})
        IO.puts("Bye!")
        System.halt(0)

      String.starts_with?(input, "/join ") ->
        new_room = String.replace_prefix(input, "/join ", "")

        case Chatex.Room.join(new_room, username) do
          :ok -> IO.puts("Joined room '#{new_room}'")
          _ -> IO.puts("Failed to join room")
        end

        input_loop(username, new_room)

      input == "/leave" ->
        if room do
          Chatex.Room.leave(room, username)
          IO.puts("Left room '#{room}'")
        end

        input_loop(username, nil)

      room != nil and input != "" ->
        Chatex.Session.send_message(username, room, input)
        input_loop(username, room)

      input != "" ->
        IO.puts("Not in a room. Use /join <room> first.")
        input_loop(username, room)

      true ->
        input_loop(username, room)
    end
  end

  defp listen_loop do
    receive do
      {:new_message, %{user: user, text: text, room_name: room}} ->
        IO.puts("\n[#{room}/#{user}]: #{text}")
        IO.write("> ")
        listen_loop()
    end
  end
end
