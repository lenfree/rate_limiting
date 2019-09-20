defmodule RateLimiting.Supervisor do
  def init(:ok) do
    children = [
      {RateLimiting.Registry, name: RateLimiting.Registry},
      {DynamicSupervisor, name: RateLimiting.BucketSupervisor, strategy: :one_for_one}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
