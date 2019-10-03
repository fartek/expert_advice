defmodule ExpertAdviceWeb.PageController do
  use ExpertAdviceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
