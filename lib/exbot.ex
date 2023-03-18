defmodule Exbot do
  require Logger

  alias Exbot.Message

  def start do
    opts = [:binary, active: false, reuseaddr: true, packet: :line]

    # irc.libera.chat

    case :gen_tcp.connect('localhost', 6667, opts) do
      {:ok, socket} ->
        with :ok <- send_message(socket, user_command("exbot")),
             :ok <- send_message(socket, nick_command("exbot")),
             :ok <- send_message(socket, join_command("##peirama")) do
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
    case :gen_tcp.recv(socket, 0, :timer.minutes(4)) do
      {:ok, message_text} ->
        Task.Supervisor.start_child(Exbot.TaskSupervisor, fn ->
          message = Message.handle(message_text)
          handle_message(socket, message)
        end)

        listen(socket, features)

      {:error, :close} ->
        Logger.error("The server connection closed. Stopping.")

      {:error, :timeout} ->
        Logger.error("The server might be dead. Stopping.")

      {:error, error} ->
        Logger.error(error)

        listen(socket, features)
    end
  end

  defp handle_message(socket, {:ping, val}) do
    send_message(socket, "PONG #{val}")
  end

  defp handle_message(socket, {:privmsg, val}) do
    cond do
      # match on mention
      Regex.match?(~r/\bexbot\b/, val.message) ->
        send_message(socket, privmsg(val.channel, "hi"))

      # match on comma start
      Regex.match?(~r/^,.+/, val.message) ->
        send_message(socket, privmsg(val.channel, "hi"))
    end

    IO.puts(val.user <> ": " <> val.message)
  end

  defp handle_message(_socket, {:srvmsg, val}) do
    IO.puts(val.user <> ": " <> val.comment)
    # Logger.warn("Unknown input: #{val}")
  end

  defp handle_message(_socket, {:unknown, val}) do
    Logger.warn("Unknown input: #{val}")
  end

  defp send_message(socket, message) do
    Logger.debug("Client: #{message}")

    :gen_tcp.send(socket, message <> "\n")
  end

  defp privmsg(user, message) do
    "PRIVMSG #{user} :#{message}"
  end

  defp user_command(user_name) do
    "USER #{user_name} * * :exbot"
  end

  defp nick_command(nick) do
    "NICK #{nick}"
  end

  defp join_command(channel) do
    "JOIN #{channel}"
  end
end
