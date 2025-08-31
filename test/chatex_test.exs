defmodule ChatexTest do
  use ExUnit.Case
  doctest Chatex

  test "greets the world" do
    assert Chatex.hello() == :world
  end
end
