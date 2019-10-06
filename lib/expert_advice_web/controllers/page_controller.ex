defmodule ExpertAdviceWeb.PageController do
  use ExpertAdviceWeb, :controller

  alias ExpertAdvice.Board
  alias ExpertAdviceWeb.Schemas.Board.PostQuestion, as: PostQuestionSchema
  alias ExpertAdviceWeb.Schemas.Board.PostAnswer, as: PostAnswerSchema

  @question_post_success "Question posted successfully!"
  @question_post_fail "Could not post question. Check the fields and try again."
  @answer_post_success "Answer posted successfully!"

  def index(conn, _params) do
    questions = Board.list_questions()
    params = %{questions: questions}
    render(conn, "index.html", params)
  end

  def show(conn, %{"slug" => slug}) do
    details = Board.show_details(slug)
    changeset = PostAnswerSchema.changeset()

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

  def answer(conn, params) do
    params["post_answer"]
    |> PostAnswerSchema.changeset()
    |> do_answer(conn, params["slug"])
  end

  defp do_answer(%{valid?: true} = schema, conn, slug) do
    account = Guardian.Plug.current_resource(conn)
    question = Board.show_details(slug)

    result =
      %{author: account.user, is_deleted?: false, question_id: question.id}
      |> Map.merge(schema.changes)
      |> Board.post_answer()

    case result do
      {:ok, _} ->
        conn
        |> put_flash(:info, @answer_post_success)
        |> redirect(to: Routes.page_path(conn, :show, slug))

      {:error, _} ->
        conn
        |> put_flash(:error, "Error while posting answer!")
        |> render("new.html", changeset: schema)
    end
  end

  defp do_answer(changeset, conn, slug) do
    error_message = changeset |> PostAnswerSchema.extract_errors() |> parse_answer_error()

    conn
    |> put_flash(:error, error_message)
    |> redirect(to: Routes.page_path(conn, :show, slug))
  end

  defp parse_answer_error(%{content: [{message, error_params} | _]}) do
    validation = Keyword.fetch!(error_params, :validation)

    case validation do
      :required ->
        "Answer " <> message

      :length ->
        count = Keyword.fetch!(error_params, :count)
        full_message = "Answer " <> message
        String.replace(full_message, "%{count}", Integer.to_string(count))
    end
  end

  defp parse_answer_error(_), do: "Something went wrong!"
end
