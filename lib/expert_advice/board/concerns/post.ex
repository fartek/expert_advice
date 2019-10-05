defmodule ExpertAdvice.Board.Concerns.Post do
  @moduledoc """
  This module describes the behaviour which the entities of the domain logic layer
  for the Board context must adhere to
  """
  alias ExpertAdviceStorage.Board.Post
  alias ExpertAdvice.Board.{Answer, Question}

  @type post_domain_struct :: Answer.t() | Question.t()
  @type post_domain_module :: Answer | Question
  @type from_post_opt :: {:load_answers, boolean}

  @callback from_post(Post.t(), [from_post_opt]) :: post_domain_struct
end
