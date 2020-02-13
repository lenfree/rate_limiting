use Mix.Config

config :rate_limiting,
  interval_seconds: 10,
  max_requests_count: 5

config :mnesia,
  dir: '.mnesia/#{Mix.env()}/#{node()}'
