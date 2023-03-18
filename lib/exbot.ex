defmodule Exbot do
  require Logger

  alias Exbot.Message

  def start do
    opts = [:binary, active: false, reuseaddr: true, packet: :line]

    case :gen_tcp.connect('localhost', 6667, opts) do
           {:ok, socket} ->
             with :ok <- send_message(socket, user_command("exbot")),
                  :ok <- send_message(socket, nick_command("exbot")),
                  :ok <- send_message(socket, bot_mode_command()),
                  :ok <- send_message(socket, join_command("foobar"))do
               Logger.info("listening..")

               listen(socket)
             else
               e ->
                 Logger.error(e)
             end

             {:ok, %{socket: socket}}

           {:error, :econnrefused} ->
             Logger.error("The server cannot be reached")
    end
  end

  defp listen(socket, features \\ []) do
    case :gen_tcp.recv(socket, 0, :timer.minutes(2)) do
      {:ok, message_text} ->
        message = Message.handle(message_text)
        handle_message(socket, message)
        listen(socket, features)

      {:error, :close} ->
        Logger.error("Connection closed.")

      {:error, error} ->
        Logger.error(error)

        listen(socket, features)
    end
  end

  defp handle_message(socket, {:ping, val}) do
    send_message(socket, "PONG #{val}")
  end

  defp handle_message(_socket, {:unknown, val}) do
    Logger.warn("Unknown input: #{val}")
  end

  defp handle_message(_socket, {:command, %{message: _message} = val}) do
    Logger.info("Command input: #{inspect(val)}")
  end

  defp send_message(socket, message) do
    Logger.debug("Client: #{message}")

    :gen_tcp.send(socket, message <> "\n")
  end

  defp user_command(user_name) do
    "USER #{user_name} * * :Hi, I'm a bot"
  end

  defp nick_command(nick) do
    "NICK #{nick}"
  end

  defp join_command(channel) do
    "JOIN ##{channel}"
  end

  defp bot_mode_command() do
    "MODE exbot +b"
  end
end
