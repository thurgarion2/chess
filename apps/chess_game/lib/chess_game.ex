defmodule ChessGame do

  @high_pieces %{
    {0, 0} => {:Rook, :white},
    {0, 7} => {:Rook, :black},
    {2, 0} => {:Bishop, :white},
    {2, 7} => {:Bishop, :black},
    {1, 0} => {:Knight, :white},
    {1, 7} => {:Knight, :black},
    {3, 0} => {:Queen, :white},
    {3, 7} => {:Queen, :black},
    {4, 0} => {:King, :white},
    {4, 7} => {:King, :black},
    {5, 0} => {:Bishop, :white},
    {5, 7} => {:Bishop, :black},
    {6, 0} => {:Knight, :white},
    {6, 7} => {:Knight, :black},
    {7, 0} => {:Rook, :white},
    {7, 7} => {:Rook, :black}
  }


  defstruct [:board, :turn]

  def new(), do: %ChessGame{board: create_board(), turn: :white}
  def new(pieces, turn), do: %ChessGame{board: pieces, turn: turn}

  defp create_board() do
    pawns =
      for x <- 0..7,
          y <- [1, 6],
          do: if(y == 1, do: {{x, y}, {:Pawn, :white}}, else: {{x, y}, {:Pawn, :black}})

    Map.merge(@high_pieces, Map.new(pawns))
  end

  def play!(game, player, from, to) do
    game
    |> valid_move!(player, from, to)
    |> move_piece(from, to)
    |> next_player()
  end

  defp valid_move!(game, player, from, to) do
    cond do
      !valid_move?(game, player, from, to) -> raise ArgumentError
      true -> game
    end
  end

  def valid_move?(game, player, from, to) do
    valid_player?(game, player) &&
      piece_owned_by_player?(game, player, from) &&
      valid_possible_move?(game, from, to)
  end

  defp valid_player?(%ChessGame{turn: color}, color), do: true
  defp valid_player?(_game, _color), do: false

  defp piece_owned_by_player?(game, player, coord),
    do: color_of_tile(game, coord) == player

  defp color_of_tile(game, coord) do
    case Map.get(game.board, coord, :empty) do
      :empty -> :empty
      {_, color} -> color
    end
  end

  defp valid_possible_move?(game, from, to),
    do: to in all_possible_moves(game, from)

  def all_possible_moves(game, from) do
    piece = piece_at_tile(game, from)

    all_possible_moves(game, piece, from)
    |> Enum.filter(&can_occupy_case?(game, &1))
  end

  def all_possible_moves_per_pieces(%ChessGame{board: board, turn: turn} = game) do
    board
    |> Map.to_list()
    |> Enum.filter(fn {_, {_,color}} -> color == turn end)
    |> Enum.map(fn {tile, _} ->
        {tile, ChessGame.all_possible_moves(game, tile)} end)
  end

  defp piece_at_tile(game, from) do
    case Map.get(game.board, from, :empty) do
      :empty -> :empty
      {piece, _} -> piece
    end
  end

  defp all_possible_moves(_game, :empty, _from), do: []
  defp all_possible_moves(game, :Rook, from), do: lines(game, from)
  defp all_possible_moves(game, :Bishop, from), do: diagonales(game, from)
  defp all_possible_moves(game, :Queen, from),
    do: lines(game, from) ++ diagonales(game, from)
  defp all_possible_moves(game, :King, from),
    do: lines(game, from, 1) ++ diagonales(game, from, 1)
  defp all_possible_moves(_game, :Knight, {x, y}),
    do:
      for(a <- [2, -2], b <- [1, -1], do: [{a + x, b + y}, {b + x, a + y}])
      |> List.flatten()
  defp all_possible_moves(game, :Pawn, {x, y}) do
    color = game.turn

    straight =
      cond do
        color == :white and y == 1 -> straight(game, [{x, y + 1}, {x, y + 2}])
        color == :white -> straight(game, [{x, y + 1}])
        color == :black and y == 6 -> straight(game, [{x, y - 1}, {x, y - 2}])
        color == :black -> straight(game, [{x, y - 1}])
      end

    diag =
      case color do
        :white -> [{x + 1, y + 1}, {x - 1, y + 1}]
        :black -> [{x + 1, y - 1}, {x - 1, y - 1}]
      end

    (diag
     |> Enum.filter(fn coord ->
       color_of_tile(game, coord) != :empty
     end)) ++ straight
  end

  defp straight(game, tiles) do
    tiles
    |> Enum.take_while(fn coord -> color_of_tile(game, coord) == :empty end)
  end

  defp lines(game, coord, limit \\ 8) do
    [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
    |> Enum.flat_map(&available_tile_in_dir(game, coord, &1, limit))
  end

  defp diagonales(game, coord, limit \\ 8) do
    [{1, 1}, {1, -1}, {-1, 1}, {-1, -1}]
    |> Enum.flat_map(&available_tile_in_dir(game, coord, &1, limit))
  end

  defp available_tile_in_dir(game, {x, y} = _from, {dx, dy} = _dir, limit) do
    1..limit
    |> Enum.map(fn nb -> {x + nb * dx, y + dy * nb} end)
    |> take_until(fn coord -> color_of_tile(game, coord) == :empty end)
  end

  defp take_until(enum, fun, acc \\ [])
  defp take_until([], _fun, acc), do: acc |> Enum.reverse()

  defp take_until([el | rest], fun, acc) do
    cond do
      fun.(el) -> take_until(rest, fun, [el | acc])
      true -> [el | acc] |> Enum.reverse()
    end
  end

  defp can_occupy_case?(game, coord),
    do: in_boundary(coord) && color_of_tile(game, coord) != game.turn

  defp in_boundary({x, y}), do: x >= 0 and x <= 7 and y >= 0 and y <= 7

  defp move_piece(game, from, to) do
    piece = Map.fetch!(game.board, from)

    board =
      game.board
      |> Map.delete(from)
      |> Map.put(to, piece)

    %ChessGame{game | board: board}
  end

  defp next_player(%ChessGame{turn: color} = game) do
    case color do
      :white -> %ChessGame{game | turn: :black}
      :black -> %ChessGame{game | turn: :white}
    end
  end
end

defimpl String.Chars, for: ChessGame do
  def to_string(%ChessGame{board: board}) do
    0..7
    |> Enum.map_join("\n", &line(board, &1))
  end

  defp line(board, y),
    do: 0..7 |> Enum.map_join(&tile_to_char(Map.get(board, {&1, y})))

  defp tile_to_char(nil), do: "_"
  defp tile_to_char({:Rook, _color}), do: "R"
  defp tile_to_char({:Bishop, _color}), do: "B"
  defp tile_to_char({:Knight, _color}), do: "K"
  defp tile_to_char({:Queen, _color}), do: "Q"
  defp tile_to_char({:King, _color}), do: "W"
  defp tile_to_char({:Pawn, _color}), do: "P"
end
