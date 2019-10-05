defmodule ExpertAdviceStorage.BoardTest do
  use ExpertAdviceStorage.DataCase

  alias ExpertAdviceStorage.Board
  alias ExpertAdviceStorage.Factory

  describe "list_root_posts/1" do
    test "returns an empty list if no posts are saved" do
      assert Board.list_root_posts() == []
    end

    test "returns all root posts (newest first) if no criteria are passed" do
      post_1 = Factory.insert!(:post, title: "title 1", slug: "title-1")
      post_2 = Factory.insert!(:post, title: "title 2", slug: "title-2")
      Factory.insert!(:post, parent_id: post_1.id)

      post_1 = Repo.preload(post_1, :subposts)
      post_2 = Repo.preload(post_2, :subposts)

      assert Board.list_root_posts() == [post_2, post_1]
    end

    test "returns all posts matching at least 1 tag" do
      post_1 = Factory.insert!(:post, title: "title 1", slug: "title-1", tags: ["elixir", "js"])

      post_2 =
        Factory.insert!(:post, title: "title 2", slug: "title-2", tags: ["js", "vue", "reach"])

      post_3 = Factory.insert!(:post, title: "title 3", slug: "title-3", tags: ["elixir"])
      Factory.insert!(:post)

      post_1 = Repo.preload(post_1, :subposts)
      post_2 = Repo.preload(post_2, :subposts)
      post_3 = Repo.preload(post_3, :subposts)

      assert Board.list_root_posts(tags: ["elixir", "js"]) == [post_3, post_2, post_1]
    end

    test "returns all posts containing the text" do
      post_1 = Factory.insert!(:post, title: "question 1", slug: "question-1", body: "body 1")
      post_2 = Factory.insert!(:post, title: "question 2", slug: "question-2", body: "body 2")

      post_3 =
        Factory.insert!(:post,
          title: nil,
          slug: nil,
          body: "answering with question 2!",
          parent_id: post_1.id
        )

      post_4 = Factory.insert!(:post, title: "question 3", slug: "question-3", body: "body 3")

      post_1 = Repo.preload(post_1, :subposts)
      post_2 = Repo.preload(post_2, :subposts)
      post_3 = Repo.preload(post_3, :subposts)
      post_4 = Repo.preload(post_4, :subposts)

      assert Board.list_root_posts(contains: "question 2") == [post_2, post_1]
    end

    test "limit the number of posts after applying search filters" do
      post_1 = Factory.insert!(:post, title: "question 1", slug: "question-1", body: "body 1")
      post_2 = Factory.insert!(:post, title: "question 2", slug: "question-2", body: "body 2")

      post_3 =
        Factory.insert!(:post,
          title: nil,
          slug: nil,
          body: "answering with question 2!",
          parent_id: post_1.id
        )

      post_4 = Factory.insert!(:post, title: "question 3", slug: "question-3", body: "body 3")

      post_1 = Repo.preload(post_1, :subposts)
      post_2 = Repo.preload(post_2, :subposts)
      post_3 = Repo.preload(post_3, :subposts)
      post_4 = Repo.preload(post_4, :subposts)

      assert Board.list_root_posts(contains: "question 2", limit: 1) == [post_2]
    end
  end

  describe "get_post_with_subposts_by_slug/1" do
    test "returns a post with subposts if found by slug" do
      post_1 = Factory.insert!(:post, title: "question 1", slug: "question-1", body: "body 1")
      post_2 = Factory.insert!(:post, parent_id: post_1.id)
      Factory.insert!(:post, title: "question 2", slug: "question-2", body: "body 2")

      post_1 = Repo.preload(post_1, :subposts)

      assert Board.get_post_with_subposts_by_slug("question-1") == post_1
    end

    test "returns nil if not found" do
      assert Board.get_post_with_subposts_by_slug("question-1") == nil
    end
  end
end
