defmodule RateLimitingTest do
  use ExUnit.Case
  doctest RateLimiting

  test "greets the world" do
    assert RateLimiting.hello() == :world
  end
end
