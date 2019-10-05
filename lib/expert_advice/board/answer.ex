defmodule ExpertAdvice.Board.Answer do
  @moduledoc """
  The domain entity that represents an answer in the board
  """

  alias __MODULE__
  alias ExpertAdvice.Board.Author
  alias ExpertAdviceStorage.Board, as: BoardStorage

  @type t :: %Answer{
          content: binary,
          author: Author.t()
        }

  defstruct content: "",
            author: nil

  @spec from_post(BoardStorage.Post.t()) :: Answer.t()
  def from_post(post) do
    %Answer{content: post.body, author: Author.from_user(post.author)}
  end
end
