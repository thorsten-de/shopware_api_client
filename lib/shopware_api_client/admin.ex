defmodule ShopwareApiClient.Admin do
  @adapter {Tesla.Adapter.Finch, name: ShopwareFinch}

  def client() do
    config = Application.fetch_env!(:shopware_api_client, :admin)

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

  def authenticate(config) do
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

  def authenticate(username, password) do
    config = Application.fetch_env!(:shopware_api_client, :admin)

    result =
      [
        {Tesla.Middleware.BaseUrl, config[:base_url]},
        Tesla.Middleware.JSON
      ]
      |> Tesla.client(@adapter)
      |> Tesla.post("/oauth/token", %{
        client_id: "administration",
        grant_type: "password",
        scopes: "write",
        username: username,
        password: password
      })

    with {:ok,
          %{
            body: %{
              "access_token" => token,
              "refresh_token" => refresh_token,
              "expires_in" => expires
            }
          }} <- result do
      {:ok, %{access_token: token, refresh_token: refresh_token, expires_in: expires}}
    else
      _whatever -> :error
    end
  end

  def info() do
    result =
      client()
      |> Tesla.get("_info/version")

    with {:ok, %{body: %{"version" => version}}} <- result do
      {:ok, version}
    end
  end

  defp search_api(entity, suffix, opts) do
    client()
    |> Tesla.post("/search#{suffix}/#{entity}", build_search_filter(opts))
  end

  def search(entity, opts) do
    with {:ok, %{body: %{"data" => data}}} <- search_api(entity, "", opts) do
      data
    end
  end

  def search_ids(entity, opts) do
    with {:ok, %{body: %{"data" => data}}} <- search_api(entity, "-ids", opts) do
      data
    end
  end

  def get(entity, opts) do
    case search(entity, Map.merge(opts, %{limit: 1})) do
      [item | _] -> item
      _ -> nil
    end
  end

  def get_id(entity, opts) do
    case search_ids(entity, Map.merge(opts, %{limit: 1})) do
      [item | _] -> item
      _ -> nil
    end
  end

  def create(entity, opts) do
    result =
      client()
      |> Tesla.post("/#{entity}", opts)

    with {:ok, %{body: body}} <- result do
      {:ok, body}
    end
  end

  def build_search_filter(%{filter: filter} = opts) do
    %{opts | filter: build_filter_list(filter)}
  end

  def build_search_filter(opts), do: opts

  defp build_filter_list([single_filter]) do
    [build_filter(single_filter)]
  end

  defp build_filter_list(multiple_filters) when is_list(multiple_filters) do
    [%{type: :multi, operator: :and, queries: Enum.map(multiple_filters, &build_filter/1)}]
  end

  defp build_filter({field, value}) do
    %{type: :equals, field: field, value: value}
  end

  defp build_filter(other), do: other
end
