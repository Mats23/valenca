defmodule Valenca.Repo.Master do
  use Ecto.Repo, otp_app: :garuda, adapter: Ecto.Adapters.Postgres
  use Scrivener, page_size: 10
end
