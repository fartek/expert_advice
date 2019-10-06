defmodule ExpertAdviceStorage.BoardTest do
  use ExpertAdviceStorage.DataCase

  alias ExpertAdviceStorage.Board
  alias ExpertAdviceStorage.Factory

  setup do
    account = Factory.insert!(:account)
    user = Factory.insert!(:user, account_id: account.id)

    %{valid_params: %{author_id: user.id}}
  end

  describe "list_root_posts/1" do
    test "returns an empty list if no posts are saved" do
      assert Board.list_root_posts() == []
    end

    test "returns all root posts (newest first) if no criteria are passed", context do
      post_1 =
        Factory.insert!(:post,
          title: "title 1",
          slug: "title-1",
          author_id: context.valid_params.author_id
        )

      post_2 =
        Factory.insert!(:post,
          title: "title 2",
          slug: "title-2",
          author_id: context.valid_params.author_id
        )

      Factory.insert!(:post, parent_id: post_1.id, author_id: context.valid_params.author_id)

      post_1 = Repo.preload(post_1, :author)
      post_2 = Repo.preload(post_2, :author)

      assert Board.list_root_posts() == [post_2, post_1]
    end

    test "returns all posts matching at least 1 tag", context do
      post_1 =
        Factory.insert!(:post,
          title: "title 1",
          slug: "title-1",
          tags: ["elixir", "js"],
          author_id: context.valid_params.author_id
        )

      post_2 =
        Factory.insert!(:post,
          title: "title 2",
          slug: "title-2",
          tags: ["js", "vue", "reach"],
          author_id: context.valid_params.author_id
        )

      post_3 =
        Factory.insert!(:post,
          title: "title 3",
          slug: "title-3",
          tags: ["elixir"],
          author_id: context.valid_params.author_id
        )

      Factory.insert!(:post, author_id: context.valid_params.author_id)

      post_1 = Repo.preload(post_1, :author)
      post_2 = Repo.preload(post_2, :author)
      post_3 = Repo.preload(post_3, :author)

      assert Board.list_root_posts(tags: ["elixir", "js"]) == [post_3, post_2, post_1]
    end

    test "returns all posts containing the text", context do
      post_1 =
        Factory.insert!(:post,
          title: "question 1",
          slug: "question-1",
          body: "body 1",
          author_id: context.valid_params.author_id
        )

      post_2 =
        Factory.insert!(:post,
          title: "question 2",
          slug: "question-2",
          body: "body 2",
          author_id: context.valid_params.author_id
        )

      Factory.insert!(:post,
        title: nil,
        slug: nil,
        body: "answering with question 2!",
        parent_id: post_1.id,
        author_id: context.valid_params.author_id
      )

      Factory.insert!(:post,
        title: "question 3",
        slug: "question-3",
        body: "body 3",
        author_id: context.valid_params.author_id
      )

      post_1 = Repo.preload(post_1, :author)
      post_2 = Repo.preload(post_2, :author)

      assert Board.list_root_posts(contains: "question 2") == [post_2, post_1]
    end

    test "limit the number of posts after applying search filters", context do
      post_1 =
        Factory.insert!(:post,
          title: "question 1",
          slug: "question-1",
          body: "body 1",
          author_id: context.valid_params.author_id
        )

      post_2 =
        Factory.insert!(:post,
          title: "question 2",
          slug: "question-2",
          body: "body 2",
          author_id: context.valid_params.author_id
        )

      Factory.insert!(:post,
        title: nil,
        slug: nil,
        body: "answering with question 2!",
        parent_id: post_1.id,
        author_id: context.valid_params.author_id
      )

      Factory.insert!(:post,
        title: "question 3",
        slug: "question-3",
        body: "body 3",
        author_id: context.valid_params.author_id
      )

      post_2 = Repo.preload(post_2, :author)

      assert Board.list_root_posts(contains: "question 2", limit: 1) == [post_2]
    end

    test "list only not deleted posts", context do
      post =
        Factory.insert!(:post,
          title: "question 1",
          slug: "question-1",
          body: "body 1",
          author_id: context.valid_params.author_id
        )

      Factory.insert!(:post,
        title: "question 2",
        slug: "question-2",
        body: "body 2",
        author_id: context.valid_params.author_id,
        is_deleted: true
      )

      post = Repo.preload(post, :author)
      assert Board.list_root_posts() == [post]
    end
  end

  describe "get_post_with_subposts_by_slug/1" do
    test "returns a post with subposts if found by slug", context do
      post =
        Factory.insert!(:post,
          title: "question 1",
          slug: "question-1",
          body: "body 1",
          author_id: context.valid_params.author_id
        )

      Factory.insert!(:post, parent_id: post.id, author_id: context.valid_params.author_id)

      Factory.insert!(:post,
        title: "question 2",
        slug: "question-2",
        body: "body 2",
        author_id: context.valid_params.author_id
      )

      post = Repo.preload(post, author: [], subposts: [author: []])

      assert Board.get_post_with_subposts_by_slug("question-1") == post
    end

    test "returns nil if not found" do
      assert Board.get_post_with_subposts_by_slug("question-1") == nil
    end

    test "returns even deleted posts", context do
      post =
        Factory.insert!(:post,
          title: "question 1",
          slug: "question-1",
          body: "body 1",
          author_id: context.valid_params.author_id,
          is_deleted: true
        )

      post = Repo.preload(post, author: [], subposts: [author: []])

      assert Board.get_post_with_subposts_by_slug("question-1") == post
    end
  end

  describe "patch_post/2" do
    test "update the post if found by id", context do
      post =
        Factory.insert!(:post,
          title: "post",
          slug: "post",
          body: "body 1",
          author_id: context.valid_params.author_id
        )

      assert {:ok, new_post} = Board.patch_post(post.id, %{body: "body 2"})
      assert new_post.body == "body 2"
    end

    test "return an error tuple if not found" do
      assert Board.patch_post(Ecto.UUID.generate(), %{body: "body 2"}) == {:error, :not_found}
    end

    test "return an error tuple if invalid changeset", context do
      Factory.insert!(:post,
        title: "taken",
        slug: "taken",
        body: "taken",
        author_id: context.valid_params.author_id
      )

      post =
        Factory.insert!(:post,
          title: "post",
          slug: "post",
          body: "body 1",
          author_id: context.valid_params.author_id
        )

      assert {:error, changeset} = Board.patch_post(post.id, %{title: "taken"})

      assert %{title: [{"has already been taken", _}]} =
               Ecto.Changeset.traverse_errors(changeset, & &1)
    end
  end

  describe "delete_post/1" do
    test "delete the post if found by id", context do
      post =
        Factory.insert!(:post,
          title: "post",
          slug: "post",
          body: "body 1",
          author_id: context.valid_params.author_id,
          is_deleted: false
        )

      assert {:ok, new_post} = Board.delete_post(post.id)
      assert new_post.is_deleted == true
    end

    test "return an error tuple if not found" do
      assert Board.delete_post(Ecto.UUID.generate()) == {:error, :not_found}
    end
  end

  describe "get_post_by_slug/1" do
    test "returns post if found by slug", context do
      post =
        Factory.insert!(:post,
          title: "question 1",
          slug: "question-1",
          body: "body 1",
          author_id: context.valid_params.author_id
        )

      post = Repo.preload(post, :author)

      assert Board.get_post_by_slug("question-1") == post
    end

    test "returns nil if not found" do
      assert Board.get_post_by_slug("slug") == nil
    end
  end

  describe "get_post/1" do
    test "returns post if found by id", context do
      post =
        Factory.insert!(:post,
          title: "question 1",
          slug: "question-1",
          body: "body 1",
          author_id: context.valid_params.author_id
        )

      post = Repo.preload(post, :author)

      assert Board.get_post(post.id) == post
    end

    test "returns nil if not found" do
      assert Board.get_post(Ecto.UUID.generate()) == nil
    end
  end
end
