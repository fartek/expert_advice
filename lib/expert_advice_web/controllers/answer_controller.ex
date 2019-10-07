defmodule ExpertAdviceWeb.AnswerController do
  use ExpertAdviceWeb, :controller

  alias ExpertAdvice.Board
  alias ExpertAdviceWeb.Schemas.Board.PostAnswer, as: PostAnswerSchema

  @answer_post_success "Answer posted successfully!"
  @answer_edit_success "Answer edited successfully!"
  @answer_edit_fail "Cannot update answer. Check your input and try again."

  def create(conn, params) do
    params["post_answer"]
    |> PostAnswerSchema.changeset()
    |> do_create(conn, params["slug"])
  end

  defp do_create(%{valid?: true} = schema, conn, slug) do
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

  defp do_create(changeset, conn, slug) do
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

  def delete(conn, params) do
    id = params["id"]
    slug = params["slug"]

    case Board.inspect_answer(id) do
      nil ->
        conn
        |> put_flash(:error, "Cannot delete an answer that does not exist")
        |> redirect(to: Routes.question_path(conn, :show, slug))

      answer ->
        author = Guardian.Plug.current_resource(conn).user
        do_delete(conn, answer, author, slug)
    end
  end

  defp do_delete(conn, %{author: %{id: id}, is_deleted?: false} = answer, %{id: id}, slug) do
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

  defp do_delete(conn, _answer, _author, slug) do
    conn
    |> put_flash(:error, "You do not have the rights to delete this answer")
    |> redirect(to: Routes.question_path(conn, :show, slug))
  end

  def edit(conn, params) do
    id = params["id"]
    slug = params["slug"]
    user = Guardian.Plug.current_resource(conn).user

    case Board.inspect_answer(id) do
      nil ->
        conn
        |> put_flash(:error, "Cannot edit answer that does not exist")
        |> redirect(to: Routes.question_path(conn, :index))

      answer ->
        do_edit(answer, conn, user, slug)
    end
  end

  defp do_edit(%{id: id, author: %{id: author_id}} = answer, conn, %{id: author_id}, slug) do
    changeset =
      answer
      |> Map.from_struct()
      |> PostAnswerSchema.changeset()

    render(conn, "edit.html", changeset: changeset, slug: slug, id: id)
  end

  defp do_edit(_answer, conn, _author, slug) do
    conn
    |> put_flash(:error, "You do not have the rights to edit this answer!")
    |> redirect(to: Routes.question_path(conn, :show, slug))
  end

  def update(conn, params) do
    slug = params["slug"]
    id = params["id"]

    params["post_answer"]
    |> PostAnswerSchema.changeset()
    |> do_update(conn, slug, id)
  end

  defp do_update(%{valid?: true} = schema, conn, slug, id) do
    user_id = Guardian.Plug.current_resource(conn).user.id

    case Board.inspect_answer(id) do
      nil ->
        conn
        |> put_flash(:error, "Cannot update answer which does not exist.")
        |> redirect(Routes.question_path(conn, :index))

      %{author: %{id: author_id}} = answer when author_id == user_id ->
        case Board.edit_answer(answer, schema.changes) do
          :ok ->
            conn
            |> put_flash(:info, @answer_edit_success)
            |> redirect(to: Routes.question_path(conn, :show, slug))

          {:error, changeset} ->
            conn
            |> put_flash(:error, @answer_edit_fail)
            |> render("edit.html", changeset: changeset, slug: slug)
        end
    end
  end

  defp do_update(changeset, conn, slug, id) do
    new_changeset = Map.put(changeset, :action, :insert)

    conn
    |> put_flash(:error, @answer_edit_fail)
    |> render("edit.html", changeset: new_changeset, slug: slug, id: id)
  end
end
