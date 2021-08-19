defmodule ChessGame.WaitingList do
  use Agent
  require Logger

  def start_link(_opts) do
    Logger.info "start waiting list"
    Agent.start_link(fn -> :none end, name: __MODULE__)
  end

  def add_user(pid) do
    Agent.update(__MODULE__, fn
      :none -> {:some, pid}
      {:some, other_pid} ->
        create_game(pid, other_pid)
        :none
    end)
  end

  defp create_game(player1, player2) do
    {:ok, game} = DynamicSupervisor.start_child(ChessGame.Supervisor.games_pool(), ChessGame.Server)
    send(player1, {:game_started, game})
    send(player2, {:game_started, game})
  end
end
