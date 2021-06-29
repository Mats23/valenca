defmodule Valenca.Package_Travel do
  use Ecto.Schema

  schema "package_travel" do
    has_one :ticket, Valenca.Ticket
    has_one :hotel, Valenca.Hotel
    has_one :extra, Valenca.Extra
    field :date_expiration, :utc_datetime
  end

end
