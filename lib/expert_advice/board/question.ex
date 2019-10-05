defmodule ExpertAdvice.Board.Question do
  @moduledoc """
  The domain entity that represents a question in the board
  """

  @behaviour ExpertAdvice.Board.Concerns.Post

  alias __MODULE__
  alias ExpertAdvice.Board.{Answer, Author}
  alias ExpertAdviceStorage.Board, as: BoardStorage
  alias ExpertAdvice.Board.Parsers.Post, as: PostParser
  alias ExpertAdvice.Board.Concerns.Post, as: PostConcern

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

  @impl true
  @spec from_post(BoardStorage.Post.t(), [PostConcern.from_post_opt()]) :: Question.t()
  def from_post(post, opts \\ []) do
    load_answers = opts[:load_answers] || false

    question = %Question{
      title: post.title,
      slug: post.slug,
      content: post.body,
      tags: post.tags,
      author: Author.from_user(post.author),
      number_of_views: post.number_of_views
    }

    if load_answers do
      %Question{question | answers: PostParser.parse_from_posts(post.subposts, Answer)}
    else
      question
    end
  end

  @spec to_post_params(Question.t()) :: map
  def to_post_params(question) do
    %{
      title: question.title,
      body: question.content,
      tags: question.tags,
      parent_id: nil,
      author_id: question.author.id,
      number_if_views: 0
    }
  end
end