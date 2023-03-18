defmodule Exbot.Handler do
  def handle("PING " <> val) do
    {:ping, val}
  end

  def handle(val) do
    command_regex =
      ~r/^:(?<user>\S+) +(?<command>\S+) +(?<params>[^:]+) *?:?(?<comment>.*)$/

    case Regex.scan(command_regex, val) do
      [[_, user, "PRIVMSG", channel, message]] ->
        {
          :privmsg,
          %{
            user: user,
            channel: String.trim(channel),
            message: String.trim(message)
          }
        }
      [[_, user, command, params, comment]] ->
        {
          :srvmsg,
          %{
            user: user,
            command: command,
            params: params,
            comment: comment
          }
        }
      [] ->
        {:unknown, val}
    end
  end
end
