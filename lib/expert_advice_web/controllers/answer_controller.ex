defmodule ExpertAdviceWeb.AnswerController do
  use ExpertAdviceWeb, :controller

  alias ExpertAdvice.Board
  alias ExpertAdviceWeb.Schemas.Board.PostAnswer, as: PostAnswerSchema

  @answer_post_success "Answer posted successfully!"

  def answer(conn, params) do
    params["post_answer"]
    |> PostAnswerSchema.changeset()
    |> do_answer(conn, params["slug"])
  end

  defp do_answer(%{valid?: true} = schema, conn, slug) do
    account = Guardian.Plug.current_resource(conn)
    question = Board.inspect_question_by_slug(slug)

    result =
      %{author: account.user, is_deleted?: false, question_id: question.id}
      |> Map.merge(schema.changes)
      |> post_answer_if_question_exists(question)

    case result do
      {:ok, _} ->
        conn
        |> put_flash(:info, @answer_post_success)
        |> redirect(to: Routes.question_path(conn, :show, slug))

      {:error, _} ->
        conn
        |> put_flash(:error, "Error while posting answer!")
        |> redirect(to: Routes.question_path(conn, :show, slug))
    end
  end

  defp do_answer(changeset, conn, slug) do
    error_message = changeset |> PostAnswerSchema.extract_errors() |> parse_answer_error()

    conn
    |> put_flash(:error, error_message)
    |> redirect(to: Routes.question_path(conn, :show, slug))
  end

  defp post_answer_if_question_exists(changes, %{is_deleted?: false}) do
    Board.post_answer(changes)
  end

  defp post_answer_if_question_exists(_, _), do: {:error, :question_is_deleted}

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

  def delete_answer(conn, params) do
    id = params["id"]
    slug = params["slug"]

    case Board.inspect_answer(id) do
      nil ->
        conn
        |> put_flash(:error, "Cannot delete an answer that does not exist")
        |> redirect(to: Routes.question_path(conn, :show, slug))

      answer ->
        author = Guardian.Plug.current_resource(conn).user
        do_delete_answer(conn, answer, author, slug)
    end
  end

  defp do_delete_answer(conn, %{author: %{id: id}, is_deleted?: false} = answer, %{id: id}, slug) do
    case Board.delete_answer(answer) do
      :ok ->
        conn
        |> put_flash(:info, "Answer deleted successfully!")
        |> redirect(to: Routes.question_path(conn, :show, slug))

      _ ->
        conn
        |> put_flash(:error, "Error while deleting answer")
        |> redirect(to: Routes.question_path(conn, :show, slug))
    end
  end

  defp do_delete_answer(conn, _answer, _author, slug) do
    conn
    |> put_flash(:error, "You do not have the rights to delete this answer")
    |> redirect(to: Routes.question_path(conn, :show, slug))
  end
end
