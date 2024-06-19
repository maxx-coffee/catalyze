defmodule Catalyze.Repo do
  use Ecto.Repo,
    otp_app: :catalyze,
    adapter: Ecto.Adapters.Postgres
end
