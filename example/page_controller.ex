defmodule RestWeb.PageController do
  use RestWeb, :controller

  def index(conn, _params) do
    source_address =
      conn.remote_ip
      |> Tuple.to_list()
      |> Enum.join(".")

    # This is just for demo purposes. For Phoenix, it's recommended to
    # write a plug for this.
    case RateLimiting.allow?(source_address) do
      {:ok, response} ->
        list = [1, 2, 3, 4]
        json(conn, list)

      {:error, response} ->
        conn
        |> put_status(response.response_code)
        |> json(%{message: response.response_message})
    end
  end
end
