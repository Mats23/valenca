defmodule Valenca.Hotel do
  use Ecto.Schema

  schema "hotel" do
    field :name, :string
    field :cnpj, :string
    field :city, :string
  end
end
