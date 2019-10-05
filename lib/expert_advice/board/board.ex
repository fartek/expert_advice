defmodule ExpertAdvice.Board do
  @moduledoc """
  The domain logic module for the board
  """

  alias ExpertAdvice.Board.Question
  alias ExpertAdviceStorage.Board, as: BoardStorage

  @spec list_questions([BoardStorage.criterion()]) :: any
  def list_questions(criteria \\ []) do
    criteria
    |> BoardStorage.list_root_posts()
    |> parse_from_posts(Question)
  end

  @spec parse_from_posts([BoardStorage.Post.t()], module) :: [module]
  defp parse_from_posts(posts, domain_module) do
    # Turn Posts into Questions/Answers asynchronously
    posts
    |> Stream.map(&Task.async(domain_module, :from_post, [&1]))
    |> Stream.map(&Task.await/1)
    |> Enum.to_list()
  end
end
