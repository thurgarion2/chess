defmodule ChessOnline.Repo do
  use Ecto.Repo,
    otp_app: :chess_online,
    adapter: Ecto.Adapters.Postgres
end
