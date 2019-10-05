defmodule ExpertAdvice.Board.Parsers.Post do
  @moduledoc """
  Helper module for transforming Post entities from the DB layer to the
  domain logic layer.
  """

  alias ExpertAdviceStorage.Board, as: BoardStorage
  alias ExpertAdvice.Board.Concerns.Post, as: PostConcern

  @typep post :: BoardStorage.Post.t()
  @typep domain_module :: PostConcern.post_domain_module()
  @typep domain_struct :: PostConcern.post_domain_struct()
  @typep opt :: PostConcern.from_post_opt()

  @spec parse_from_post(post, domain_module, [opt]) :: domain_struct | nil
  def parse_from_post(post, domain_module, opts \\ []) do
    [post]
    |> parse_from_posts(domain_module, opts)
    |> Enum.at(0)
  end

  @spec parse_from_posts([post], domain_module, [opt]) :: [domain_struct]
  def parse_from_posts(posts, domain_module, opts \\ []) do
    # Turn Posts into Questions/Answers asynchronously
    posts
    |> Stream.map(&Task.async(domain_module, :from_post, [&1, opts]))
    |> Stream.map(&Task.await/1)
    |> Enum.to_list()
  end
end
