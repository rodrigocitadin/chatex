# Chatex

Chatex is a distributed command-line chat application built with Elixir and OTP, running on the BEAM virtual machine. It allows multiple users to join chat rooms and communicate in real-time. The application leverages OTP's distribution capabilities to automatically connect with other users running Chatex on the same local network.

## Features

- Real-time messaging within chat rooms.
- Create and join different rooms dynamically.
- Automatic discovery of other Chatex nodes on the same machine or local network.
- Standalone executable for easy execution.

## How to Run

To get started with Chatex, you need to have Elixir and Erlang installed on your system.

### 1. Build the Executable

First, compile the project into a standalone executable file using Mix:

```bash
mix escript.build
```

This command will create an executable file named `chatex` in the root directory of the project.

### 2. Run the Application

Once the build is complete, you can start the chat client by running the generated file:

```bash
./chatex
```

You will be prompted to choose a username, and then you can start using the application's commands. To simulate a multi-user chat, you can open several terminal windows and run the `./chatex` command in each one.

## Usage

After launching the application and choosing a username, you can interact with the chat system using the following commands.

- `/join <room_name>`: Joins a specific chat room. If the room does not exist, it will be created automatically.
- `/leave`: Leaves the current chat room.
- `/help`: Displays a list of all available commands.
- `/exit`: Disconnects from the chat and terminates the application.

When inside a room, any text that does not start with a `/` will be sent as a message to all other users in that room.

## Current Limitations

- **Local Area Network Only**: The application is designed to run on a single machine or on a local area network (LAN). Nodes on different, separate networks cannot discover or communicate with each other.
- **Room Discovery**: You and other users need to know the room name to connect.
- **Security**: Since we are running only on a local area network, we have no security, but in the future I will add room passwords and user verification.
