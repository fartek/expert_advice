defmodule ExpertAdvice.Board.AuthorTest do
  use ExUnit.Case, async: true

  alias ExpertAdvice.Board.Author
  alias ExpertAdviceStorage.Factory

  describe "from_user/1" do
    test "creates an Author from a User" do
      user = Factory.build(:user, display_name: "t")
      author = Author.from_user(user)

      assert author.display_name == user.display_name
    end
  end
end
