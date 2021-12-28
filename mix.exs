defmodule ShopwareApiClient.MixProject do
  use Mix.Project

  def project do
    [
      app: :shopware_api_client,
      version: "0.1.0",
      elixir: "~> 1.13",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ShopwareApiClient.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # HTTP-Client für die Shopware-Integration
      {:tesla, "~>1.4"},
      {:finch, "~>0.10"},
      {:jason, "~>1.2"},
      {:elixir_uuid, "~>1.2.0"}
    ]
  end
end
