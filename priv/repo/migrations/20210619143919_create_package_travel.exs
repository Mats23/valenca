defmodule Valenca.Repo.Migrations.CreatePackageTravel do
  use Ecto.Migration

  def change do
    create table(:package_travel) do
      add :ticket_id, references(:ticket)
      add :hotel_id, references(:hotel)
      add :extra_id, references(:extra)
      add :data_expiration, :utc_datetime

    end
  end
end
