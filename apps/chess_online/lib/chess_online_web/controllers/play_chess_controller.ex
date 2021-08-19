defmodule ChessOnlineWeb.PlayChessController do
  use ChessOnlineWeb, :controller

  def show(conn, _params) do
    render(conn, "show.html")
  end
end
