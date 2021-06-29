defmodule Valenca.Client.ClientsServices do
  alias Valenca.{
    Client,
    Repo
  }
  require Logger

  def create(client, params) do
    with {:ok, created_client} <- Client.create_client(client ,params) do
      created_client
    end
  end

  def get_all do
    clients =
      Client
      |> Repo.all()
    {:ok, clients}
  end
end
