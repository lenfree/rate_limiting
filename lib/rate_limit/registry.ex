defmodule RateLimiting.Registry do
  use GenServer
  alias Timex.Duration

  @server __MODULE__

  @interval_seconds Application.get_env(:rate_limiting, :interval_seconds)
  @max_requests_count Application.get_env(:rate_limiting, :max_requests_count)

  ## Client API
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, [], name: @server)
  end

  @doc """
  Looks up the bucket pid for `name` stored in `table`.
  Returns `{:ok, pid}` if the bucket exists, `:error` otherwise.
  """
  def lookup(_table_name, source_ip_address) do
    case GenServer.call(__MODULE__, {:search, source_ip_address}) do
      {:lookup_table, nil} -> create(nil, source_ip_address)
      {:lookup_table, config} -> {:ok, config}
    end
  end

  def delete(_table_name, source_ip_address) do
    GenServer.call(__MODULE__, {:delete, source_ip_address})
  end

  def create(_table_name, source_ip_address) do
    params = %RateLimiting.Config{
      time_request_made: DateTime.utc_now(),
      count: 0,
      interval_seconds: @interval_seconds,
      max_requests_count: @max_requests_count,
      duration_in_seconds: 0,
      source_ip_address: source_ip_address,
      valid: true
    }

    case GenServer.call(__MODULE__, {:create, source_ip_address, params}) do
      {:lookup_table, config} ->
        {:ok, config}

      _ ->
        nil
    end
  end

  def update(_table_name, params) do
    params = Map.update(params, :count, 1, &(&1 + 1))

    case GenServer.call(__MODULE__, {:create, params.source_ip_address, params}) do
      {:lookup_table, config} ->
        {:ok, config}

      _ ->
        nil
    end
  end

  ## Server callbacks

  def init(_opts) do
    table = :ets.new(:lookup_table, [:named_table, read_concurrency: true])
    refs = %{}
    {:ok, {table, refs}}
  end

  def handle_call({:create, source_ip_address, params}, _from, opts) do
    :ets.insert(:lookup_table, {source_ip_address, params})
    {:reply, {:lookup_table, params}, opts}
  end

  def handle_call({:search, source_ip_address}, _from, opts) do
    case :ets.lookup(:lookup_table, source_ip_address) do
      [{^source_ip_address, config}] ->
        {:ok, config}
        {:reply, {:lookup_table, config}, opts}

      _ ->
        {:reply, {:lookup_table, nil}, opts}
    end
  end

  def handle_call({:delete, source_ip_address}, _from, opts) do
    :ets.delete(:lookup_table, source_ip_address)
    {:reply, {:lookup_table, nil}, opts}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
