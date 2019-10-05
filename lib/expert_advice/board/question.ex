defmodule ExpertAdvice.Board.Question do
  @moduledoc """
  The domain entity that represents a question in the board
  """

  alias __MODULE__
  alias ExpertAdvice.Board.{Answer, Author}
  alias ExpertAdviceStorage.Board, as: BoardStorage

  @type t :: %Question{
          title: binary,
          slug: binary,
          content: binary,
          tags: [binary],
          author: Author.t(),
          answers: :not_loaded | [Answer.t()],
          number_of_views: pos_integer
        }

  defstruct title: nil,
            slug: nil,
            content: "",
            tags: [],
            author: nil,
            answers: :not_loaded,
            number_of_views: 0

  @spec from_post(BoardStorage.Post.t()) :: Question.t()
  def from_post(post) do
    %Question{
      title: post.title,
      slug: post.slug,
      content: post.body,
      tags: post.tags,
      author: Author.from_user(post.author),
      number_of_views: post.number_of_views
    }
  end
end
