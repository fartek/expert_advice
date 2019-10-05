defmodule ExpertAdvice.Board.Answer do
  @moduledoc """
  The domain entity that represents an answer in the board
  """

  @behaviour ExpertAdvice.Board.Concerns.Post

  alias __MODULE__
  alias ExpertAdvice.Board.Author
  alias ExpertAdviceStorage.Board, as: BoardStorage
  alias ExpertAdvice.Board.Concerns.Post, as: PostConcern

  @type t :: %Answer{
          content: binary,
          author: Author.t()
        }

  defstruct content: "",
            author: nil

  @impl true
  @spec from_post(BoardStorage.Post.t(), [PostConcern.from_post_opt()]) :: Answer.t()
  def from_post(post, _opts \\ []) do
    %Answer{content: post.body, author: Author.from_user(post.author)}
  end
end
