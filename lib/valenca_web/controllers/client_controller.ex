defmodule ValencaWeb.ClientController do
  use ValencaWeb, :controller
  require Logger
  alias Valenca.{
    Client
  }
  alias Valenca.Client.{
    ClientsServices
  }
  def index(conn, _params) do
    with {:ok, clients} <- ClientsServices.get_all() do
      render(conn, "list.json", %{clients: clients})
    end
  end

  def create(conn, params) do
    with client <- ClientsServices.create(%Client{}, params) do
      render(conn, "show.json", %{client: client})
    end
  end
end
