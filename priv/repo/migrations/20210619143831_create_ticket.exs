defmodule Valenca.Repo.Migrations.CreateTicket do
  use Ecto.Migration

  def change do
    create table(:ticket) do
      add :origin, :string
      add :destiny, :string
      add :date_boarding, :utc_datetime
      add :date_back, :utc_datetime
    end
  end
end
