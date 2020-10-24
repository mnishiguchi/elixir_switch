defmodule ElixirSwitchTest do
  use ExUnit.Case
  doctest ElixirSwitch

  test "greets the world" do
    assert ElixirSwitch.hello() == :world
  end
end
