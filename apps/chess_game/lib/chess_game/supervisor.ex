defmodule ChessGame.Supervisor do
  use Supervisor



  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    children = [
      ChessGame.WaitingList,
      {DynamicSupervisor, strategy: :one_for_one, name: games_pool()}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  def games_pool(), do: ChessGame.DynamicSupervisor

end
