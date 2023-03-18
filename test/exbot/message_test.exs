defmodule Exbot.MessageTest do
  use ExUnit.Case

  alias Exbot.Message

  test "handle PING with a value" do
    assert Message.handle("PING foo") == {:ping, "foo"}
  end

  test "handle unknown message" do
    assert Message.handle("asdf sadf") == {:unknown, "asdf sadf"}
  end

  test "handle PRIVMSG" do
    assert Message.handle(
             ":wilhelm!~u@653jrvr8yyu5n.irc PRIVMSG #foobar :hello World"
           ) ==
             {
               :privmsg,
               %{
                 user: "wilhelm!~u@653jrvr8yyu5n.irc",
                 channel: "#foobar",
                 message: "hello World"
               }
             }
  end

  test "handle feature message" do
    message = ":melissa.local 005 exbot draft/CHATHISTORY=1000" <>
      " :are supported by this server\r\n"

    assert Message.handle(message) ==
             {
              :srvmsg,
              %{
                user: "melissa.local",
                command: "005",
                comment: "are supported by this server\r",
                params: "exbot draft/CHATHISTORY=1000 "
              }
            }
  end

  test "handle 254" do
    message = ":melissa.local 254 exbot 2 :channels formed\r\n"

    assert Message.handle(message) ==
             {
               :srvmsg,
               %{
                 user: "melissa.local",
                 command: "254",
                 comment: "channels formed\r",
                 params: "exbot 2 "
               }
             }
  end

  test "handle JOIN" do
    message = ":exbot!~u@ewiijp2dqfc6q.irc JOIN #foobar"

    assert Message.handle(message) == {
              :srvmsg,
              %{
                user: "exbot!~u@ewiijp2dqfc6q.irc",
                command: "JOIN",
                comment: "",
                params: "#foobar"
              }
            }
  end
end
