defmodule ExpertAdviceWeb.PageController do
  use ExpertAdviceWeb, :controller

  alias ExpertAdvice.Board

  def index(conn, _params) do
    questions = Board.list_questions()
    params = %{questions: questions}
    render(conn, "index.html", params)
  end

  def show(conn, %{"slug" => slug}) do
    details = Board.show_details(slug)
    changeset = ExpertAdviceStorage.Board.Post.changeset(%{})

    params = %{details: details, changeset: changeset}
    render(conn, "show.html", params)
  end

  def patch(conn, _slug, _params) do
    questions = Board.list_questions()
    params = %{questions: questions}
    render(conn, "index.html", params)
  end
end
