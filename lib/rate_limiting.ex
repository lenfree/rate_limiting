defmodule RateLimiting do
  @moduledoc """
  A rate limiting plugin that validates whether
  source IP address is allowed to make a connection.
  """
  alias RateLimiting.Request

  @doc """
  Checks whether source ip address is allowed to make request
  based on max requests count within a minute. Assumes that
  input is of IPv4 format, 1.2.3.4.

  ## Examples

      iex> RateLimiting.allow?("1.2.3.4")
      {:error, %RateLimiting.Config{
          count: 100,
          duration_in_seconds: 0,
          interval_seconds: 60,
          max_requests: 100,
          time_request_made: %DateTime{},
          response_code: 429,
          response_message: "Rate limit exceeded. Try again in 60 seconds.",
          source_ip_address: "1.2.3.4",
          valid?: false,
        }
      }

  """
  # TODO: see if we can add source_ip_address
  # format parser to validate entry.
  def allow?(source_ip_address) do
    case Request.allow?(source_ip_address) do
      params ->
        case params.valid do
          true ->
            {:ok, params}

          false ->
            message = Request.parse_error_message(params)
            {:error, message}
        end
    end
  end
end
