defmodule SubwayTest do
  use ExUnit.Case
  doctest Subway

  test "greets the world" do
    assert Subway.hello() == :world
  end
end
