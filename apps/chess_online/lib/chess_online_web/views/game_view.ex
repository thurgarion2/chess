defmodule ChessOnlineWeb.GameView do
  use ChessOnlineWeb, :view



  def render("game.json", game) do
    valid_moves = ChessGame.all_possible_moves_per_pieces(game)

    %{board: view_json("board", game.board),
      valid_moves: view_json("valid_moves", valid_moves)}
  end

  defp view_json("valid_moves", moves),
    do: moves
    |> Enum.map(fn {tile, tiles} ->
      {view_json("tile", tile), Enum.map(tiles, &view_json("tile", &1))} end)
    |> Map.new()

  defp view_json("board", board),
    do: board
    |> Map.to_list()
    |> Enum.map(fn {tile, piece} ->
      {view_json("tile", tile), view_json("piece", piece)} end)
    |> Map.new()

  defp view_json("tile", {x,y}), do: "#{x},#{y}"
  defp view_json("piece", {piece,color}), do: %{piece: piece, color: color}

end
