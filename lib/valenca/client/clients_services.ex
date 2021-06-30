defmodule Valenca.Client.ClientsServices do
  alias Valenca.{
    Client,
    Repo
  }

  require Logger

  def create(%{"cpf" => cpf} = params) do
    case Client.exist?(cpf) do
      true -> {:error, :client_exist}
      false -> Client.create_client(%Client{}, params)
    end
  end

  def get_all do
    clients =
      Client
      |> Repo.all()

    {:ok, clients}
  end

  def find_by_id(id) do
    with {:ok, client} <- Client.find_by_id(id) do
      client
    end
  end
end
