defmodule Valenca.Repo.Migrations.CreateExtra do
  use Ecto.Migration

  def change do
    create table(:extra) do
      add :name, :string
    end
  end
end
