defmodule Valenca.Ticket do
  use Ecto.Schema

  schema "ticket" do
    field(:origin, :string)
    field(:destiny, :string)
    field(:date_boarding, :utc_datetime)
    field(:date_back, :utc_datetime)
  end
end
