defmodule ExpertAdvice.Board do
  @moduledoc """
  The domain logic module for the board
  """

  alias ExpertAdvice.Board.Question
  alias ExpertAdviceStorage.Board, as: BoardStorage
  alias ExpertAdvice.Board.Parsers.Post, as: PostParser

  @spec list_questions([BoardStorage.criterion()]) :: [Question.t()]
  def list_questions(criteria \\ []) do
    criteria
    |> BoardStorage.list_root_posts()
    |> PostParser.parse_from_posts(Question)
  end
end
