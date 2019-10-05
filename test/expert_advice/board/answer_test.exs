defmodule ExpertAdvice.Board.AnswerTest do
  use ExUnit.Case, async: true

  alias ExpertAdvice.Board.Answer
  alias ExpertAdviceStorage.Factory

  describe "from_post/1" do
    test "creates a Answer from a Post" do
      user = Factory.build(:user)
      post = Factory.build(:post, author: user)
      question = Answer.from_post(post)

      assert question.content == post.body
      assert question.author.display_name == post.author.display_name
      assert question.question_id == post.parent_id
    end
  end
end
