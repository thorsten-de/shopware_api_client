defmodule ShopwareApiClient.Admin do
  @default_config [
    base_url: "http://localhost/api",
    credentials: %{
      grant_type: "client_credentials",
      client_id: "SWIABELTQ2VPTMLRVE1STHNYUG",
      client_secret: "NnZ5UDdvcVg2dXNRV3NrYzR6bHJ4RlpTemZvZ2lvVEU2N0NPR1k"
    }
  ]

  @adapter {Tesla.Adapter.Finch, name: ShopwareFinch}

  def client(config \\ @default_config) do
    with {:ok, auth_token} <- authenticate(config) do
      [
        {Tesla.Middleware.BaseUrl, config[:base_url]},
        {Tesla.Middleware.BearerAuth, token: auth_token},
        {Tesla.Middleware.Headers, [{"accept", "application/json"}]},
        Tesla.Middleware.JSON
      ]
      |> Tesla.client(@adapter)
    end
  end

  def authenticate(config \\ @default_config) do
    result =
      [
        {Tesla.Middleware.BaseUrl, config[:base_url]},
        Tesla.Middleware.JSON
      ]
      |> Tesla.client(@adapter)
      |> Tesla.post("/oauth/token", config[:credentials])

    with {:ok, %{body: %{"access_token" => token}}} <- result do
      {:ok, token}
    end
  end

  def info(config \\ @default_config) do
    result =
      config
      |> client()
      |> Tesla.get("_info/version")

    with {:ok, %{body: %{"version" => version}}} <- result do
      {:ok, version}
    end
  end

  def search(config \\ @default_config, entity, opts \\ %{}) do
    result =
      config
      |> client()
      |> Tesla.post("/search/#{entity}", opts)

    with {:ok, %{body: body}} <- result do
      {:ok, body}
    end
  end
end
