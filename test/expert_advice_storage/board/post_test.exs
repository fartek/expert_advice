defmodule ExpertAdviceStorage.Board.PostTest do
  use ExpertAdviceStorage.DataCase

  alias ExpertAdviceStorage.Factory
  alias ExpertAdviceStorage.Board.Post

  setup do
    %{
      valid_params: %{
        title: "valid_title",
        body: "valid_body",
        tags: ["valid_tag_1", "valid_tag_2"],
        parent_id: nil
      }
    }
  end

  describe "changeset/1" do
    test "creates a valid changeset for valid params", context do
      changeset = Post.changeset(context.valid_params)
      assert changeset.valid?
      assert changeset.changes.title == "valid_title"
      assert changeset.changes.body == "valid_body"
      assert changeset.changes.tags == ["valid_tag_1", "valid_tag_2"]
    end

    test "generates a slug", context do
      changeset = Post.changeset(context.valid_params)
      assert changeset.valid?
      assert changeset.changes.slug == "valid-title"
    end

    test "returns an error if cannot generate a slug from the title", context do
      params = Map.put(context.valid_params, :title, "😀")
      changeset = Post.changeset(params)
      refute changeset.valid?

      errors = Changeset.traverse_errors(changeset, & &1)
      assert %{title: [{"must contain only url-safe characters", _}]} = errors
    end

    test "throws away non-allowed properties", context do
      params = Map.put(context.valid_params, :random_param, "value")
      refute params |> Post.changeset() |> Map.has_key?(:random_param)
    end

    test "requires specific properties", context do
      params_no_title = Map.delete(context.valid_params, :title)
      params_no_body = Map.delete(context.valid_params, :body)
      params_no_tags = Map.delete(context.valid_params, :tags)

      refute Post.changeset(params_no_title).valid?
      refute Post.changeset(params_no_body).valid?
      refute Post.changeset(params_no_tags).valid?
    end

    test "assures no duplicate titles are created", context do
      Factory.insert!(:post, title: "valid_title", slug: "unique-slug")

      assert {:error, changeset} = context.valid_params |> Post.changeset() |> Repo.insert()
      errors = Changeset.traverse_errors(changeset, & &1)
      assert %{title: [{"has already been taken", _}]} = errors
    end

    test "assures no duplicate slugs are created", context do
      Factory.insert!(:post, title: "unique_title", slug: "valid-title")

      assert {:error, changeset} = context.valid_params |> Post.changeset() |> Repo.insert()
      errors = Changeset.traverse_errors(changeset, & &1)
      assert %{slug: [{"has already been taken", _}]} = errors
    end
  end
end
