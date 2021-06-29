defmodule Valenca.Factory do
  use ExMachina.Ecto, repo: Valenca.Repo

  def client_factory do
    %Valenca.Client{
      name: "Fulano",
      cpf: "12345678910",
      email: "fulago@fg.com",
      phone: "71988888888"
    }
  end
end
