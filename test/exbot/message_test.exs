defmodule Exbot.MessageTest do
  use ExUnit.Case

  alias Exbot.Message

  test "handle PING with a value" do
    assert Message.handle("PING foo") == {:ping, "foo"}
  end

  test "handle unknown message" do
    assert Message.handle("asdf sadf") == {:unknown, "asdf sadf"}
  end

  test "handle feature message" do
    message = ":melissa.local 005 exbot draft/CHATHISTORY=1000" <>
      " :are supported by this server\r\n"

    assert Message.handle(message) ==
             {
               :command,
               %{
                 code: "005",
                 type: :feature,
                 name: "melissa.local",
                 user: "exbot",
                 message: "are supported by this server",
                 args: %{
                   prefix: "draft",
                   value: "1000",
                   key: "CHATHISTORY"
                 }
               }
             }
  end

  test "handle 254" do
    message = ":melissa.local 254 exbot 2 :channels formed\r\n"

    assert Message.handle(message) ==
             {
               :command,
               %{
                 code: "254",
                 type: :user_channels,
                 name: "melissa.local",
                 user: "exbot",
                 message: "channels formed",
                 args: %{
                   channels: 2
                 }
               }
             }
  end

  test "handle 001" do
    message = ":melissa.local 001 exbot :Welcome to the ErgoTest IRC Network exbot\r\n"

    assert Message.handle(message) ==
             {
               :command,
               %{
                 code: "001",
                 type: :server_message,
                 name: "melissa.local",
                 user: "exbot",
                 message: "Welcome to the ErgoTest IRC Network exbot",
                 args: %{}
               }
             }
  end

  test "handle JOIN" do
    message = ":exbot!~u@ewiijp2dqfc6q.irc JOIN #foobar"

    assert {:join, %{user: _, channel: "#foobar"}} =
             Message.handle(message)
  end
end
