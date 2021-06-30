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
    with {:ok, client} <- ClientsServices.create(params) do
      render(conn, "show.json", %{client: client})
    else
      {:error, :client_exist} -> send_resp(conn, 409, "")
    end
  end

  def show(conn, %{"id" => id}) do
    with client <- ClientsServices.find_by_id(id) do
      render(conn, "list.json", %{clients: client})
    end
  end
end
