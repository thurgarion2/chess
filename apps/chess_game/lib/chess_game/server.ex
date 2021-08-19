defmodule ChessGame.Server do
  use GenServer

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, new_server())
  end

  defp new_server(), do: %{game: ChessGame.new(), black: nil, white: nil}

  @impl true
  def init(init_arg) do
    {:ok, init_arg}
  end

  def register_player(game) do
    case GenServer.call(game, {:register, self()}) do
      :error -> false
      color -> color
    end
  end

  @impl true
  def handle_call({:register, player}, _from, %{white: nil}=state),
    do:  {:reply, :white, %{state | white: player} }
  def handle_call({:register, player}, _from, %{black: nil}=state) do
    state = %{state | black: player}
    update_players(state)

    {:reply, :black, %{state | black: player} }
  end
  def handle_call({:register, _player}, _from, state),
    do:  {:noreply, :error, state}


  defp update_players(%{white: p_white, black: p_black, game: game}) do
    case game.turn do
      :white -> send(p_white, {:play, game})
        send(p_black, {:wait, game})
      :black -> send(p_black, {:play, game})
        send(p_white, {:wait, game})
    end
  end

  def play(game, p_color, from, to),
    do: GenServer.cast(game, {:play, p_color, from, to})

  @impl true
  def handle_cast({:play, p_color, from, to}, %{game: game} = state) do
    state = %{state | game: ChessGame.play!(game, p_color, from, to)}
    update_players(state)
    {:noreply, state}
  end

end
