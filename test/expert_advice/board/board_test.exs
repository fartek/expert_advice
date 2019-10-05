defmodule ExpertAdvice.BoardTest do
  use ExpertAdviceStorage.DataCase

  alias ExpertAdvice.Board
  alias ExpertAdvice.Board.{Answer, Question}
  alias ExpertAdviceStorage.Factory

  describe "list_questions/1" do
    test "returns an empty list if no questions posted" do
      assert Board.list_questions() == []
    end

    test "returns a list of questions if some are posted" do
      account = Factory.insert!(:account)
      user = Factory.insert!(:user, account_id: account.id)
      post = :post |> Factory.insert!(author_id: user.id) |> Repo.preload(:author)
      question = Question.from_post(post)

      assert Board.list_questions() == [question]
    end
  end

  describe "show_details/1" do
    test "return nil if question does not exist" do
      assert Board.show_details("random") == nil
    end

    test "return the question with the correct slug + answers" do
      account = Factory.insert!(:account)
      user = Factory.insert!(:user, account_id: account.id)
      question = Factory.insert!(:post, slug: "slug", author_id: user.id)

      answer_1 =
        :post
        |> Factory.insert!(
          title: nil,
          slug: nil,
          author_id: user.id,
          parent_id: question.id,
          body: "ans 1"
        )
        |> Repo.preload(:author)
        |> Answer.from_post()

      answer_2 =
        :post
        |> Factory.insert!(
          title: nil,
          slug: nil,
          author_id: user.id,
          parent_id: question.id,
          body: "ans 2"
        )
        |> Repo.preload(:author)
        |> Answer.from_post()

      details = Board.show_details("slug")

      assert details.slug == "slug"
      assert details.answers == [answer_1, answer_2]
    end
  end
end
