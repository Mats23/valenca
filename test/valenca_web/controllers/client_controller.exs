defmodule ValencaWeb.ClientControllerTest do
  use ValencaWeb.ConnCase

  describe "Test client" do
    test "GET All clients" do
      response =
        build_conn()
        |> get("/api/client")
        |> json_response(200)

      assert length(response["data"]) > 0
    end

    test "Create Client" do
      req_body = %{
        "name" => "Beltrano",
        "cpf" => "12345678122",
        "email" => "123@gnail.com",
        "phone" => "71999884495"
      }

      response =
        build_conn()
        |> post("/api/client", req_body)
        |> json_response(200)

      assert Map.equal?(response, req_body)
    end

    test "Find by id" do
      response =
        build_conn()
        |> get("/api/client/1")
        |> json_response(200)

      assert response != nil
    end
  end
end
