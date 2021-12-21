defmodule ShopwareApiClient.Tests.AdminClientTest do
  use ExUnit.Case
  alias ShopwareApiClient.Admin

  @client_config [
    base_url: "http://localhost/api",
    credentials: %{
      grant_type: "client_credentials",
      client_id: "SWIABELTQ2VPTMLRVE1STHNYUG",
      client_secret: "NnZ5UDdvcVg2dXNRV3NrYzR6bHJ4RlpTemZvZ2lvVEU2N0NPR1k"
    }
  ]

  test "gets an auth token" do
    assert {:ok, _token} = Admin.authenticate(@client_config)
  end

  test "gets api information" do
    assert {:ok, _infos} = Admin.info(@client_config)
  end

  test "retrieves search data" do
    result = Admin.search(@client_config, "customer", %{limit: 10})

    assert {:ok, _data} = result
  end
end
