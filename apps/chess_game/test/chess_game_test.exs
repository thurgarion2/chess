defmodule ChessGameTest do
  use ExUnit.Case
  doctest ChessGame

  test "Rook can move correctly" do
    valid_moves = [{0,1},{1,0}] ++
      (2..7 |> Enum.flat_map(fn nb -> [{nb,1}, {1,nb}] end))

    game = ChessGame.new(%{{1,1}=> {:Rook, :white}}, :white)
    test_all_possibles_moves(game, {1,1}, valid_moves)

    game = ChessGame.new(%{{1,1}=> {:Rook, :black}}, :black)
    test_all_possibles_moves(game, {1,1}, valid_moves)
  end

  test "Rook can take pieces" do
    game = ChessGame.new(%{{0,0}=> {:Rook, :white}, {0,7} => {:Rook, :black}}, :white)
    assert test_moving_piece(game, {0,0}, {0,7})
  end

  test "Rook blocked by pieces" do
    valid_moves = (for x <- 1..3, do: {x,0}) ++ (for y <- 1..2, do: {0,y})

    game = ChessGame.new(%{{0,0}=> {:Rook, :white},
      {0,3} => {:Pawn, :white},
      {3,0} => {:Pawn, :black} }, :white)
    test_all_possibles_moves(game, {0,0}, valid_moves)

    game = ChessGame.new(%{{0,0}=> {:Rook, :black},
      {0,3} => {:Pawn, :black},
      {3,0} => {:Pawn, :white} }, :black)
    test_all_possibles_moves(game, {0,0}, valid_moves)
  end

  test "Bishop can move correctly" do
    valid_moves = [{0,2},{2,0},{0,0}] ++
      (2..7 |> Enum.map(fn nb -> {nb,nb} end))

    game = ChessGame.new(%{{1,1}=> {:Bishop, :white}}, :white)
    test_all_possibles_moves(game, {1,1}, valid_moves)

    game = ChessGame.new(%{{1,1}=> {:Bishop, :black}}, :black)
    test_all_possibles_moves(game, {1,1}, valid_moves)
  end

  test "Bishop can take pieces" do
    game = ChessGame.new(%{{0,0}=> {:Bishop, :white}, {7,7} => {:Bishop, :black}}, :white)
    assert test_moving_piece(game, {0,0}, {7,7})
  end

  test "Knight can move correctly" do
    valid_moves = [{0,3},{3,0},{2,3},{3,2}]

    game = ChessGame.new(%{{1,1}=> {:Knight, :white}}, :white)
    test_all_possibles_moves(game, {1,1}, valid_moves)

    game = ChessGame.new(%{{1,1}=> {:Knight, :black}}, :black)
    test_all_possibles_moves(game, {1,1}, valid_moves)
  end

  test "Knight can take pieces" do
    game = ChessGame.new(%{{0,0}=> {:Knight, :white}, {1,2} => {:Knight, :black}}, :white)
    assert test_moving_piece(game, {0,0}, {1,2})
  end

  test "Queen can move correctly" do
    valid_moves = [{0,0},{0,1},{1,0},{2,0},{0,2}] ++
      (2..7 |> Enum.flat_map(fn nb -> [{nb,1}, {1,nb},{nb,nb}] end))

    game = ChessGame.new(%{{1,1}=> {:Queen, :white}}, :white)
    test_all_possibles_moves(game, {1,1}, valid_moves)

    game = ChessGame.new(%{{1,1}=> {:Queen, :black}}, :black)
    test_all_possibles_moves(game, {1,1}, valid_moves)
  end

  test "Queen can take pieces" do
    game = ChessGame.new(%{{0,0}=> {:Queen, :white}, {7,7} => {:Queen, :black}}, :white)
    assert test_moving_piece(game, {0,0}, {7,7})
  end

  test "King can move correctly" do
    valid_moves = for x <- 0..2, y <- 0..2, {x,y}!={1,1}, do: {x,y}

    game = ChessGame.new(%{{1,1}=> {:King, :white}}, :white)
    test_all_possibles_moves(game, {1,1}, valid_moves)

    game = ChessGame.new(%{{1,1}=> {:King, :black}}, :black)
    test_all_possibles_moves(game, {1,1}, valid_moves)
  end

  test "King can take pieces" do
    game = ChessGame.new(%{{0,0}=> {:King, :white}, {1,1} => {:King, :black}}, :white)
    assert test_moving_piece(game, {0,0}, {1,1})
  end


  test "Pawn move correctly" do
    game = ChessGame.new(%{{0,1}=> {:Pawn, :white}}, :white)
    test_all_possibles_moves(game, {0,1}, [{0,2},{0,3}])

    game = ChessGame.new(%{{0,5}=> {:Pawn, :white}}, :white)
    test_all_possibles_moves(game, {0,5}, [{0,6}])

    game = ChessGame.new(%{{0,6}=> {:Pawn, :white}}, :white)
    test_all_possibles_moves(game, {0,6}, [{0,7}])

    game = ChessGame.new(%{{0,5}=> {:Pawn, :white}, {0,6}=> {:Pawn, :black}}, :white)
    test_all_possibles_moves(game, {0,5}, [])

    game = ChessGame.new(%{{0,5}=> {:Pawn, :white}, {1,6}=> {:Pawn, :black}}, :white)
    test_all_possibles_moves(game, {0,5}, [{0,6},{1,6}])
  end

  defp test_all_possibles_moves(game, from, valid_moves) do
    assert contains_same_elements(ChessGame.all_possible_moves(game, from), valid_moves)
    assert Enum.all?(valid_moves, &test_moving_piece(game, from, &1))
  end

  defp contains_same_elements(l1, l2),
    do: Enum.sort(l1) == Enum.sort(l2)

  defp test_moving_piece(game, from, to) do
    piece = Map.get(game.board, from)

    game
    |> ChessGame.play(game.turn, from: from , to: to)
    |> piece_is_at?(to, piece)
  end

  defp piece_is_at?(game, coord, piece) do
    Map.get(game.board, coord) == piece
  end
end
