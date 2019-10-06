defmodule ExpertAdvice.Board.AnswerTest do
  use ExUnit.Case, async: true

  alias ExpertAdvice.Board.Answer
  alias ExpertAdviceStorage.Factory

  describe "from_post/1" do
    test "creates a Answer from a Post" do
      user = Factory.build(:user)
      post = Factory.build(:post, author: user)
      answer = Answer.from_post(post)

      assert answer.content == post.body
      assert answer.author.display_name == post.author.display_name
      assert answer.question_id == post.parent_id
      assert answer.id == post.id
    end
  end
end
