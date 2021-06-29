defmodule Valenca.Repo.Migrations.CreateHotel do
  use Ecto.Migration

  def change do
    create table(:hotel) do
      add :name, :string
      add :cnpj, :string
      add :city, :string
    end

  end
end
