defmodule ExpertAdvice.BoardTest do
  use ExpertAdviceStorage.DataCase

  alias ExpertAdvice.Board
  alias ExpertAdvice.Board.Question
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
end
