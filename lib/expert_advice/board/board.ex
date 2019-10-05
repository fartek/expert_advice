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
end
