defmodule ValencaWeb.PageController do
  use ValencaWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
