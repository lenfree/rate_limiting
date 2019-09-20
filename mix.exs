defmodule RateLimiting.MixProject do
  use Mix.Project

  def project do
    [
      app: :rate_limiting,
      version: "0.1.0",
      name: "rate_limiting",
      source_url: "https://github.com/lenfree/rate_limiting",
      elixir: "~> 1.9",
      start_permanent: Mix.env() == :prod,
      description: "A simple rate limiting application based on source ip address.",
      deps: deps(),
      package: package()
    ]
  end

  defp package do
    [
      maintainers: ["Lenfree Yeung"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/lenfree/rate_limiting"}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :timex],
      mod: {RateLimiting.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:timex, "~> 3.5"}
    ]
  end
end
