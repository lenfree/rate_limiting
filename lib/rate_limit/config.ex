defmodule RateLimiting.Config do
  defstruct interval_seconds: nil,
            max_requests_count: nil,
            time_request_made: nil,
            response_code: nil,
            response_message: nil,
            count: 0,
            duration_in_seconds: nil,
            error: nil,
            source_ip_address: nil,
            valid: true
end
