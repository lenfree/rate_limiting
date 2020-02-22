defmodule RateLimiting.Registry do
  use GenServer
  require IEx
  @server __MODULE__

  @interval_seconds Application.get_env(:rate_limiting, :interval_seconds)
  @max_requests_count Application.get_env(:rate_limiting, :max_requests_count)

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
    Memento.stop()
    nodes = [node() | Node.list()]

    # TODO: Investigate
    # Libcluster takes at least a second to join new nodes with gossip protocol
    Process.sleep(1000)

    case Enum.count(Node.list()) > 0 do
      true ->
        Memento.start()

        # TODO: Investigate - Seems like there's a bug with Memento for setting up cluster.
        #        Memento.add_nodes(Node.list())
        #        Memento.info()
        #        Memento.Table.set_storage_type(RateLimiting.Config, node(), :disc_copies)
        #        Memento.Table.create_copy(RateLimiting.Config, node(), :disc_copies)
        #        Memento.info()

        # Thanks to https://github.com/sheharyarn/memento/issues/17
        :mnesia.change_config(:extra_db_nodes, Node.list())
        :mnesia.change_table_copy_type(:schema, node(), :disc_copies)
        :mnesia.add_table_copy(RateLimiting.Config, node(), :disc_copies)
        Memento.info()

      false ->
        Memento.stop()
        Memento.Schema.create(nodes)
        Memento.start()
        Memento.Table.create!(RateLimiting.Config, disc_copies: nodes)
        Memento.info()
    end

    refs = %{}
    {:ok, {refs}}
  end

  def handle_call({:create, _source_ip_address, params}, _from, opts) do
    Memento.transaction!(fn ->
      Memento.Query.write(params)
    end)

    {:reply, {:lookup_table, params}, opts}
  end

  def handle_call({:search, source_ip_address}, _from, opts) do
    data =
      Memento.transaction!(fn ->
        Memento.Query.read(RateLimiting.Config, source_ip_address)
      end)

    case data do
      nil ->
        {:reply, {:lookup_table, nil}, opts}

      data ->
        {:ok, data}
        {:reply, {:lookup_table, data}, opts}
    end
  end

  def handle_call({:delete, source_ip_address}, _from, opts) do
    Memento.transaction!(fn ->
      Memento.Query.delete(RateLimiting.Config, source_ip_address)
    end)

    {:reply, {:lookup_table, nil}, opts}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end
