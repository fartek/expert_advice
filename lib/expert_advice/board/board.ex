defmodule ExpertAdvice.Board do
  @moduledoc """
  The domain logic module for the board
  """

  alias ExpertAdvice.Board.{Answer, Question}
  alias ExpertAdviceStorage.Board, as: BoardStorage
  alias ExpertAdvice.Board.Parsers.Post, as: PostParser

  @spec list_questions([BoardStorage.criterion()]) :: [Question.t()]
  def list_questions(criteria \\ []) do
    criteria
    |> BoardStorage.list_root_posts()
    |> PostParser.parse_from_posts(Question)
  end

  @spec show_details(binary) :: Question.t()
  def show_details(slug) do
    slug
    |> BoardStorage.get_post_with_subposts_by_slug()
    |> post_to_question_with_answers()
  end

  @spec post_to_question_with_answers(BoardStorage.Post.t() | nil) :: Question.t() | nil
  defp post_to_question_with_answers(nil), do: nil

  defp post_to_question_with_answers(post) do
    PostParser.parse_from_post(post, Question, load_answers: true)
  end

  @spec post_question(Question.t()) :: {:ok, BoardStorage.Post.t()} | {:error, term}
  def post_question(question) do
    question
    |> Question.to_post_params()
    |> BoardStorage.create_post()
  end

  @spec post_answer(Answer.t()) :: {:ok, BoardStorage.Post.t()} | {:error, term}
  def post_answer(question) do
    question
    |> Answer.to_post_params()
    |> BoardStorage.create_post()
  end

  @spec edit_question(Question.t(), map) :: {:ok, Question.t()} | {:error, term}
  def edit_question(question, params) do
    with {:ok, new_post} <- BoardStorage.patch_post(question.id, params) do
      new_question = show_details(new_post.slug)
      {:ok, new_question}
    end
  end

  @spec delete_question(Question.t()) :: {:ok, Question.t()} | {:error, term}
  def delete_question(question) do
    with {:ok, new_post} <- BoardStorage.delete_post(question.id) do
      new_question = show_details(new_post.slug)
      {:ok, new_question}
    end
  end

  @spec edit_answer(Answer.t(), map) :: :ok | {:error, term}
  def edit_answer(answer, params) do
    with {:ok, _} <- BoardStorage.patch_post(answer.id, params) do
      :ok
    end
  end

  @spec delete_answer(Answer.t()) :: :ok | {:error, term}
  def delete_answer(answer) do
    with {:ok, _} <- BoardStorage.delete_post(answer.id) do
      :ok
    end
  end
end
