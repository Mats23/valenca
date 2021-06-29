defmodule Valenca.Client do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query
  require Logger
  alias Valenca.{
    Repo
  }
  @type t :: %__MODULE__ {
    name: String.t(),
    cpf: String.t(),
    email: String.t(),
    phone: String.t()
  }

  schema "client" do
    field :name, :string
    field :cpf, :string
    field :email, :string
    field :phone, :string
  end

  def changeset(client, params \\ %{}) do
    client
     |> cast(params, [:name, :cpf, :email, :phone])
     |> validate_required([:name, :cpf, :email, :phone])
     |> validate_format(:email, ~r/@/)
    end

  def create_client(client, params) do
    client
    |> changeset(params)
    |> Repo.insert()
  end

end
