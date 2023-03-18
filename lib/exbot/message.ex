defmodule Exbot.Message do
  def handle("PING " <> val) do
    {:ping, val}
  end

  def handle(val) do
    case String.split(val, ":") do
      [_, command, message | rest] ->
        message = message <> Enum.join(rest, ":")

        {
          :command,
          Map.put_new(parse_command(command), :message, String.trim(message))
        }
      [_, command] ->
        parse_message(command)

      other ->
        {
          :unknown,
          Enum.join(other, ":")
        }
    end
  end

  defp parse_message(command) do
    case String.split(command, " ") do
      [name, "JOIN", channel] ->
        {:join, %{user: name, channel: channel}}
      end
  end

  defp parse_command(command) do
    case String.split(command, " ") do
      [name, code, user | params] ->
        {type, args} =  parse_command_args(code, params)

        %{
          type: type,
          code: code,
          name: name,
          user: user,
          args: args
        }
    end
  end

  defp parse_command_args("001", _), do: {:server_message, %{}}
  defp parse_command_args("002", _), do: {:server_message, %{}}
  defp parse_command_args("003", _), do: {:server_message, %{}}
  defp parse_command_args("004", _), do: {:server_message, %{}}

  defp parse_command_args("005", [params | _]) do
    case Regex.scan(~r/(\w+)\/(\w+)=(\w+)/, params) do
      [[_, prefix, key, value]] ->
        {:feature, %{prefix: prefix, key: key, value: value}}
    end
  end

  defp parse_command_args("254", [channels | _]) do
    case Integer.parse(channels) do
      {val, _} ->
        {:user_channels, %{channels: val}}
    end
  end

  defp parse_command_args(_code, _params) do
    {:unknown, %{}}
  end
end
