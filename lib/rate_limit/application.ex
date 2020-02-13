defmodule RateLimiting.Application do
  @moduledoc false
  use Application

  def start(_type, _args) do
    topologies = [
      example: [
        strategy: Cluster.Strategy.Gossip
      ]
    ]

    children = [
      {Cluster.Supervisor, [topologies, [name: RateLimiting.ClusterSupervisor]]},
      {RateLimiting.Registry, []}
    ]

    opts = [strategy: :one_for_one, name: RateLimiting.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
