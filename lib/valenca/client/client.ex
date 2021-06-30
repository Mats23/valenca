defmodule Valenca.Client do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query, only: [from: 2]
  require Logger

  alias Valenca.{
    Repo
  }

  schema "client" do
    field(:name, :string)
    field(:cpf, :string)
    field(:email, :string)
    field(:phone, :string)
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

  def find_by_id(id),
    do:
      Repo.all(
        from(client in __MODULE__,
          where: client.id == ^id,
          select: %{
            id: client.id,
            name: client.name,
            cpf: client.cpf,
            email: client.email,
            phone: client.phone
          }
        )
      )

  def exist?(cpf), do: Repo.exists?(from(c in __MODULE__, where: c.cpf == ^cpf))
end
