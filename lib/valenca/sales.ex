defmodule Valenca.Sales do
  use Ecto.Schema

  schema "sales" do
    has_one :client, Valenca.Client
    has_one :pakcage_travel, Valenca.Package_Travel
    field :price, :string
  end
end
