defmodule ValencaWeb.ClientView do
  use ValencaWeb, :view
  require Logger

  def render("list.json", %{clients: clients}) do
    view_clients = transform_list(clients)
    %{data: view_clients}
  end

  def render("show.json",%{client: client}) do
    %{
      name: client.name,
      cpf: client.cpf,
      email: client.email,
      phone: client.phone
    }
  end

  defp transform_list(list) do
    list
    |> Enum.map(fn client ->
     %{
      id: client.id,
      name: client.name,
      cpf: client.cpf,
      email: client.email,
      phone: client.phone
     }
    end)
    |> Enum.sort(&(&1.id < &2.id))
  end
end
