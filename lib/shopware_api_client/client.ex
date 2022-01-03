defmodule ShopwareApiClient.Admin do
  @default_config Application.fetch_env!(:shopware_api_client, :admin)

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

  defp search_api(config, entity, suffix, opts) do
    config
    |> client()
    |> Tesla.post("/search#{suffix}/#{entity}", build_search_filter(opts))
  end

  def search(config \\ @default_config, entity, opts) do
    with {:ok, %{body: %{"data" => data}}} <- search_api(config, entity, "", opts) do
      data
    end
  end

  def search_ids(config \\ @default_config, entity, opts) do
    with {:ok, %{body: %{"data" => data}}} <- search_api(config, entity, "-ids", opts) do
      data
    end
  end

  def get(config \\ @default_config, entity, opts) do
    case search(config, entity, Map.merge(opts, %{limit: 1})) do
      [item | _] -> item
      _ -> nil
    end
  end

  def get_id(config \\ @default_config, entity, opts) do
    case search_ids(config, entity, Map.merge(opts, %{limit: 1})) do
      [item | _] -> item
      _ -> nil
    end
  end

  def create(config \\ @default_config, entity, opts) do
    result =
      config
      |> client()
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
