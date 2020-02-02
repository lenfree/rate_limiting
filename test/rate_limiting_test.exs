defmodule RateLimitingTest do
  use ExUnit.Case
  # doctest RateLimiting
  alias RateLimiting

  test "request should be allowed" do
    {:ok,
     %RateLimiting.Config{
       count: count,
       duration_in_seconds: duration_in_seconds,
       error: error,
       interval_seconds: interval_seconds,
       max_requests_count: max_requests_count,
       response_code: response_code,
       response_message: response_message,
       source_ip_address: source_ip_address,
       valid: valid
     }} = RateLimiting.allow?("127.0.0.1")

    assert count == 1
    assert duration_in_seconds == 0
    assert error == nil
    assert interval_seconds == 10
    assert max_requests_count == 5
    assert response_code == nil
    assert response_message == nil
    assert source_ip_address == "127.0.0.1"
    assert valid == true
  end

  test "request should not be allowed when it exceeds 5 requests for the same source ip address" do
    Enum.each(1..5, fn _x -> RateLimiting.allow?("1.2.3.4") end)

    {:error,
     %RateLimiting.Config{
       count: count,
       duration_in_seconds: duration_in_seconds,
       error: error,
       interval_seconds: interval_seconds,
       max_requests_count: max_requests_count,
       response_code: response_code,
       response_message: response_message,
       source_ip_address: source_ip_address,
       valid: valid
     }} = RateLimiting.allow?("1.2.3.4")

    assert count == 5
    assert duration_in_seconds == 0
    assert error == "request count of '5' exceeded"
    assert interval_seconds == 10
    assert max_requests_count == 5
    assert response_code == 429
    assert response_message == "Rate limit exceeded. Try again in 10 seconds"
    assert source_ip_address == "1.2.3.4"
    assert valid == false
  end
end
