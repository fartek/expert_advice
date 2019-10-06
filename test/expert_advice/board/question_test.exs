defmodule ExpertAdvice.Board.QuestionTest do
  use ExUnit.Case, async: true

  alias ExpertAdvice.Board.Question
  alias ExpertAdviceStorage.Factory

  describe "from_post/1" do
    test "creates a Question from a Post" do
      user = Factory.build(:user)

      post =
        Factory.build(:post, tags: ["tag"], number_of_views: 5, author: user, is_deleted: true)

      question = Question.from_post(post)

      assert question.title == post.title
      assert question.slug == post.slug
      assert question.content == post.body
      assert question.tags == post.tags
      assert question.author.display_name == post.author.display_name
      assert question.number_of_views == post.number_of_views
      assert question.id == post.id
      assert question.is_deleted? == post.is_deleted
    end
  end
end
