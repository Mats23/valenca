defmodule Valenca.Repo.Migrations.CreateSales do
  use Ecto.Migration

  def change do
    create table(:sales) do
      add :client_id, references(:client)
      add :package_tarvel_id, references(:package_travel)
      add :price, :string
    end
  end
end
