# RateLimiting

A simple rate limiting application for demo purposes only. Previously, it only supports
ETS but now it supports distributed DB with Mnensia and libcluster to handle node joining
cluster. Goal is to make this configurable with different backends.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `rate_limiting` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rate_limiting, "~> 0.1.4"}
  ]
end
```

To configure request count and duration:

```elixir
config :rate_limiting,
 interval_seconds: 60,
 max_requests_count: 100
```

## TODO:

Add tests!!!!

For an example, please see https://github.com/lenfree/rate_limiting/tree/master/example.

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/rate_limiting](https://hexdocs.pm/rate_limiting).
