defmodule ShopwareApiClientTest do
  use ExUnit.Case
  doctest ShopwareApiClient

  test "greets the world" do
    assert ShopwareApiClient.hello() == :world
  end
end
