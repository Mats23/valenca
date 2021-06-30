defmodule ValencaWeb.ClientView do
  use ValencaWeb, :view
  require Logger

  def render("list.json", %{clients: clients}),
    do: %{data: render_many(clients, __MODULE__, "show.json")}

  def render("show.json", %{client: client}),
    do: %{
      name: client.name,
      cpf: client.cpf,
      email: client.email,
      phone: client.phone
    }
end
