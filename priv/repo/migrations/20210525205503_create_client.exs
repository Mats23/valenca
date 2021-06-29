defmodule Valenca.Repo.Migrations.CreateClient do
  use Ecto.Migration

  def change do
    create table(:client) do
      add :name, :string
      add :email, :string
      add :cpf, :string
      add :phone, :string
    end
  end
end
