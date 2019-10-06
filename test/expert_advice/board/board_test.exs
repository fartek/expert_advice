defmodule ExpertAdvice.BoardTest do
  use ExpertAdviceStorage.DataCase

  alias ExpertAdvice.Board
  alias ExpertAdvice.Board.{Answer, Author, Question}
  alias ExpertAdviceStorage.Factory

  setup do
    account = Factory.insert!(:account)
    user = Factory.insert!(:user, account_id: account.id)
    %{account: account, user: user}
  end

  describe "list_questions/1" do
    test "returns an empty list if no questions posted" do
      assert Board.list_questions() == []
    end

    test "returns a list of questions if some are posted", context do
      post = :post |> Factory.insert!(author_id: context.user.id) |> Repo.preload(:author)
      question = Question.from_post(post)

      assert Board.list_questions() == [question]
    end
  end

  describe "show_details/1" do
    test "return nil if question does not exist" do
      assert Board.show_details("random") == nil
    end

    test "return the question with the correct slug + answers", context do
      user = context.user
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

  describe "post_question/1" do
    test "A valid Question is inserted into the DB as a Post", context do
      question = %Question{
        title: "title",
        content: "body",
        tags: ["js"],
        author: Author.from_user(context.user)
      }

      assert {:ok, post} = question |> Board.post_question()
      post = Repo.preload(post, :subposts)

      assert post.title == "title"
      assert post.body == "body"
      assert post.tags == ["js"]
      assert post.author_id == context.user.id
      assert post.number_of_views == 0
      assert post.subposts == []
    end
  end

  describe "post_answer/1" do
    test "A valid Answer is inserted into the DB as a Post", context do
      question = Factory.insert!(:post, author_id: context.user.id)

      answer = %Answer{
        content: "body",
        author: Author.from_user(context.user),
        question_id: question.id
      }

      assert {:ok, post} = answer |> Board.post_answer()

      assert post.body == "body"
      assert post.author_id == context.user.id
      assert post.parent_id == question.id
    end
  end

  describe "edit_question/2" do
    test "returns an updated struct", context do
      question = Factory.insert!(:post, author_id: context.user.id)
      assert {:ok, %{title: "edit title"}} = Board.edit_question(question, %{title: "edit title"})
    end
  end

  describe "delete_question/2" do
    test "returns an updated struct", context do
      question = Factory.insert!(:post, author_id: context.user.id, is_deleted: false)
      assert {:ok, %{is_deleted?: true}} = Board.delete_question(question)
    end
  end

  describe "edit_answer/2" do
    test "returns :ok", context do
      answer = Factory.insert!(:post, author_id: context.user.id)
      assert Board.edit_answer(answer, %{body: "edit body"}) == :ok
    end
  end

  describe "delete_answer/2" do
    test "returns :ok", context do
      answer = Factory.insert!(:post, author_id: context.user.id, is_deleted: false)
      assert Board.delete_answer(answer) == :ok

      updated_answer = Repo.get(ExpertAdviceStorage.Board.Post, answer.id)
      assert updated_answer.is_deleted == true
    end
  end

  describe "inspect_question_by_slug/1" do
    test "returns Question if found", context do
      post = Factory.insert!(:post, slug: "slug", author_id: context.user.id)
      post = Repo.preload(post, :author)
      question = Question.from_post(post)
      assert Board.inspect_question_by_slug(question.slug) == question
    end

    test "returns nil if not found" do
      assert Board.inspect_question_by_slug("none") == nil
    end
  end

  describe "inspect_answer/1" do
    test "returns Answer if found", context do
      post = Factory.insert!(:post, author_id: context.user.id)
      post = Repo.preload(post, :author)
      answer = Answer.from_post(post)
      assert Board.inspect_answer(answer.id) == answer
    end

    test "returns nil if not found" do
      assert Board.inspect_answer(Ecto.UUID.generate()) == nil
    end
  end
end
