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
          id: Ecto.UUID.t(),
          content: binary,
          author: Author.t(),
          question_id: Ecto.UUID.t(),
          is_deleted?: boolean
        }

  defstruct id: nil,
            content: "",
            author: nil,
            question_id: nil,
            is_deleted?: false

  @impl true
  @spec from_post(BoardStorage.Post.t(), [PostConcern.from_post_opt()]) :: Answer.t()
  def from_post(post, _opts \\ []) do
    %Answer{
      id: post.id,
      content: post.body,
      author: Author.from_user(post.author),
      question_id: post.parent_id,
      is_deleted?: post.is_deleted
    }
  end

  @impl true
  @spec to_post_params(Answer.t()) :: map
  def to_post_params(answer) do
    %{
      title: nil,
      body: answer.content,
      tags: [],
      parent_id: answer.question_id,
      author_id: answer.author.id,
      number_of_views: 0,
      is_deleted: answer.is_deleted?
    }
  end
end
