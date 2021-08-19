defmodule ChessOnline.ChessGameAppTest do
  use ExUnit.Case, async: true
  alias ChessOnline.ChessGame

  test "example of full utilisation" do
    start_supervised(ChessGame.Supervisor)

    ChessGame.WaitingList.add_user(self())
    ChessGame.WaitingList.add_user(self())

    game_pid = receive do
      {:new_game, pid} -> pid
    end

    assert_receive {:new_game, _}

    ChessGame.Worker.register(game_pid)
    assert_receive :white
    ChessGame.Worker.register(game_pid)
    assert_receive :black
    assert_receive {:play, _}
    assert_receive {:wait, _}


  end

end
