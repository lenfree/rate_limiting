defmodule RateLimiting.Config do
  use Memento.Table,
    attributes: [
      :source_ip_address,
      :interval_seconds,
      :max_requests_count,
      :time_request_made,
      :response_code,
      :response_message,
      :count,
      :duration_in_seconds,
      :error,
      :valid
    ]
end
