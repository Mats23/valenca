defmodule Valenca.Repo do
  use Ecto.Repo,
    otp_app: :valenca,
    adapter: Ecto.Adapters.Postgres
end
