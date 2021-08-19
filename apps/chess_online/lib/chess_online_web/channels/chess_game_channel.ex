defmodule ChessOnlineWeb.ChessGameChannel do
  use ChessOnlineWeb, :channel



  @impl true
  def join("chess_game:lobby", _params, socket) do
    ChessGame.WaitingList.add_user(self())
    {:ok, socket}
  end

  @impl true
  def handle_info({:game_started, game_pid}, socket) do
    case ChessGame.Server.register_player(game_pid) do
      :error -> raise "cannot join game"
      color ->
        socket = socket
          |> assign(:game, game_pid)
          |> assign(:player_color, color)

          Process.link(game_pid)
          push(socket, "found adversary", %{color: color})
          {:noreply, socket}
    end
  end




  def handle_info({:play, game}, socket) do
    push(socket, "play", ChessOnlineWeb.GameView.render("game.json", game))
    {:noreply, socket}
  end


  def handle_info({:wait, game}, socket) do
    push(socket, "wait", ChessOnlineWeb.GameView.render("game.json", game))
    {:noreply, socket}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("play", %{"from" => [x1,y1], "to" => [x2,y2]}, socket) do
    assigns = socket.assigns
    ChessGame.Server.play(assigns.game, assigns.player_color, {x1,y1}, {x2,y2})
    {:reply, :ok, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (chess_game:lobby).
  # @impl true
  # def handle_in("shout", payload, socket) do
  #   broadcast socket, "shout", payload
  #   {:noreply, socket}
  # end

  # # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
