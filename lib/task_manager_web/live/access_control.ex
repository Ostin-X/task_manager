defmodule TaskManagerWeb.Plugs.AccessControl do
  import Plug.Conn
  # Import this to access redirect/2 and put_flash/3
  import Phoenix.Controller

  def init(default), do: default

  def call(conn, _opts) do
    if conn.host == "localhost" and conn.port == 4000 do
      conn
    else
      conn
      |> put_flash(:error, "Access Denied")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
