defmodule ExpertAdviceWeb.QuestionController do
  use ExpertAdviceWeb, :controller

  alias ExpertAdvice.Board
  alias ExpertAdviceWeb.Schemas.Board.PostQuestion, as: PostQuestionSchema
  alias ExpertAdviceWeb.Schemas.Board.PostAnswer, as: PostAnswerSchema

  @question_post_success "Question posted successfully!"
  @question_post_fail "Could not post question. Check the fields and try again."

  def index(conn, _params) do
    questions = Board.list_questions()
    render(conn, "index.html", questions: questions)
  end

  def show(conn, %{"slug" => slug}) do
    changeset = PostAnswerSchema.changeset()

    case Board.show_details(slug) do
      nil ->
        conn
        |> put_flash(:error, "Question not found!")
        |> redirect(to: Routes.question_path(conn, :index))

      details ->
        params = %{details: details, changeset: changeset}
        render(conn, "show.html", params)
    end
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
        |> redirect(to: Routes.question_path(conn, :show, question.slug))

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

  def delete(conn, params) do
    slug = params["slug"]

    case Board.inspect_question_by_slug(slug) do
      nil ->
        conn
        |> put_flash(:error, "Cannot delete a question that does not exist")
        |> redirect(to: "/")

      question ->
        author = Guardian.Plug.current_resource(conn).user
        do_delete(conn, question, author)
    end
  end

  defp do_delete(conn, %{author: %{id: id}, is_deleted?: false} = question, %{id: id}) do
    case Board.delete_question(question) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Question deleted successfully!")
        |> redirect(to: Routes.question_path(conn, :index))

      _ ->
        conn
        |> put_flash(:error, "Error while deleting question")
        |> redirect(to: Routes.question_path(conn, :show, question.slug))
    end
  end

  defp do_delete(conn, question, _author) do
    conn
    |> put_flash(:error, "You do not have the rights to delete this question")
    |> redirect(to: Routes.question_path(conn, :show, question.slug))
  end
end
