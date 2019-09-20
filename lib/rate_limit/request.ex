defmodule RateLimiting.Request do
  alias RateLimiting.Registry
  alias Timex.Duration
  require IEx
  @max_requests_count Application.get_env(:rate_limiting, :max_requests_count)
  @interval_seconds Application.get_env(:rate_limiting, :interval_seconds)

  # TODO: Investigate if I could add IP format parser.
  def allow?(source_ip_address) do
    case Registry.lookup(:lookup_table, source_ip_address) do
      # We do a lookup if request ip address exists. Otherwise,
      # create new entry in table.
      :error ->
        {:ok, params} =
          Registry.create(nil, source_ip_address)
          |> Registry.lookup(source_ip_address)

        params

      {:ok, params} ->
        params |> valid?()
    end
  end

  # TODO: Fix hexdocs doc for this function.
  # Computes time diff from first request made and see if duration
  # is still under 60 seconds.
  def valid?(params = %RateLimiting.Config{}) do
    duration_expired?(params)
    |> valid_duration?
    |> valid_request_count?
  end

  def valid?(_) do
    # TODO: try to bubble up error message up the chain
    :error
  end

  def valid_duration?(params) do
    case get_duration(params) >= params.interval_seconds do
      true ->
        # Since first attempted request is more than duration, we
        # create a new entry in table with this timestamp.
        # Registry.create(source_ip_address)
        # add check number of request times made in 60
        Registry.update(params)
        {:ok, params} = Registry.lookup(:lookup_table, params.source_ip_address)
        Map.put(params, :valid, true)

      false ->
        update_duration(params)
    end
  end

  def valid_request_count?(params = %{valid: valid}) when valid == true do
    case params.count <= @max_requests_count do
      true ->
        {:ok, params} = Registry.update(params)
        Map.put(params, :valid, true)

      false ->
        update_duration(params, :count)
    end
  end

  def duration_expired?(params = %{duration_in_seconds: duration})
      when duration > @interval_seconds do
    # TODO: Once a source ip is allowed to make a request,
    # user have to make a new request to clear information
    # from table. This is a bug! To fix this, one solution is
    # use GenServer handle info to constantly check all
    # entries from table and clean it as required.
    {:ok, params} =
      Registry.delete(nil, params.source_ip_address)
      |> Registry.create(params.source_ip_address)
      |> Registry.lookup(params.source_ip_address)

    update_duration(params)
  end

  def duration_expired?(params) do
    update_duration(params)
  end

  def get_duration(params) do
    DateTime.diff(DateTime.utc_now(), params.time_request_made, :second)
  end

  def get_absolute_time(value) do
    Integer.to_string(value)
  end

  def duration_left(params) do
    params.interval_seconds - params.duration_in_seconds
  end

  def parse_error_message(config) do
    time = duration_left(config) |> get_absolute_time
    message = "Rate limit exceeded. Try again in #{time} seconds"

    response = Map.put(config, :response_message, message)
    Map.put(response, :response_code, 429)
  end

  def update_duration(params, :count) do
    params = Map.put(params, :duration_in_seconds, get_duration(params))
    params = Map.put(params, :valid, false)
    Map.put(params, :error, "request count of '#{@max_requests_count}' exceeded")
  end

  def update_duration(params) do
    params = Map.put(params, :duration_in_seconds, get_duration(params))
    Map.put(params, :valid, true)
  end
end
