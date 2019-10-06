defmodule ExpertAdviceWeb.PageController do
  use ExpertAdviceWeb, :controller

  alias ExpertAdvice.Board
  alias ExpertAdviceWeb.Schemas.Board.PostQuestion, as: PostQuestionSchema

  @question_post_success "Question posted successfully!"
  @question_post_fail "Could not post question. Check the fields and try again."

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

  def new(conn, _params) do
    changeset = PostQuestionSchema.changeset()
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, params) do
    params["post_question"]
    |> PostQuestionSchema.changeset()
    |> do_create(conn)
  end

  defp do_create(%{valid?: true} = schema, conn) do
    account = Guardian.Plug.current_resource(conn)

    result =
      %{tags: [], author: account.user, is_deleted?: false}
      |> Map.merge(schema.changes)
      |> Board.post_question()

    case result do
      {:ok, question} ->
        conn
        |> put_flash(:info, @question_post_success)
        |> redirect(to: Routes.page_path(conn, :show, question.slug))

      {:error, changeset} ->
        new_changeset = PostQuestionSchema.merge_with_changeset(schema, changeset)

        conn
        |> put_flash(:error, @question_post_fail)
        |> render("new.html", changeset: new_changeset)
    end
  end

  defp do_create(changeset, conn) do
    new_changeset =
      changeset
      |> PostQuestionSchema.with_tag_list_to_string()
      |> Map.put(:action, :insert)

    conn
    |> put_flash(:error, @question_post_fail)
    |> render("new.html", changeset: new_changeset)
  end
end
