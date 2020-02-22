# RateLimiting

A simple rate limiting application for demo purposes only. Previously, it only supports
ETS but now it supports distributed DB with Mnensia and libcluster to handle node joining
cluster. Goal is to make this configurable with different backends.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `rate_limiting` to your list of dependencies in `mix.exs`:

Tested on Elixir v1.10.1

```elixir
def deps do
  [
    {:rate_limiting, "~> 0.1.5"}
  ]
end
```

To configure request count and duration:

```elixir
config :rate_limiting,
 interval_seconds: 60,
 max_requests_count: 100

# Required config for mnesia disc mode
config :mnesia,
  dir: '.mnesia/#{Mix.env()}/#{node()}'

```

## TODO:

Add tests!!!!

For an example, please see https://github.com/lenfree/rate_limiting/tree/master/example.

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/rate_limiting](https://hexdocs.pm/rate_limiting).
