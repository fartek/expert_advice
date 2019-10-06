defmodule ExpertAdviceStorage.Board do
  @moduledoc """
  The context module for managing the board on the DB level.
  """

  import Ecto.Query

  alias ExpertAdviceStorage.Repo
  alias ExpertAdviceStorage.Board.Post

  @spec create_post(map) :: {:ok, Post.t()} | {:error, term}
  def create_post(params) do
    params
    |> Post.changeset()
    |> Repo.insert()
  end

  @spec get_post_with_subposts_by_slug(binary) :: Post.t() | nil
  def get_post_with_subposts_by_slug(slug) do
    Post
    |> where([p], p.slug == ^slug)
    |> join(:inner, [p], assoc(p, :author))
    |> join(:left, [p, _], assoc(p, :subposts))
    |> join(:left, [_, _, sp], assoc(sp, :author))
    |> preload([_, a, sp, spa], author: a, subposts: {sp, author: spa})
    |> order_by([_, _, sp], asc: sp.inserted_at)
    |> Repo.one()
  end

  @type criterion :: {:tags, [binary]} | {:contains, binary} | {:limit, pos_integer}
  @spec list_root_posts([criterion]) :: [Post.t()]
  def list_root_posts(criteria \\ []) do
    tags = criteria[:tags]
    contains = criteria[:contains]
    limit = criteria[:limit]

    Post
    |> where([p], is_nil(p.parent_id) and not p.is_deleted)
    |> join(:inner, [p], assoc(p, :author))
    |> join(:left, [p, _], assoc(p, :subposts))
    |> apply_tags(tags)
    |> apply_contains(contains)
    |> apply_limit(limit)
    |> preload([p, a], author: a)
    |> order_by([p], desc: p.inserted_at)
    |> Repo.all()
  end

  @spec apply_limit(Ecto.Query.t(), nil | pos_integer) :: Ecto.Query.t()
  defp apply_limit(query, nil), do: query
  defp apply_limit(query, limit), do: limit(query, ^limit)

  @spec apply_tags(Ecto.Query.t(), nil | [binary]) :: Ecto.Query.t()
  defp apply_tags(query, nil), do: query
  defp apply_tags(query, []), do: query
  defp apply_tags(query, tags), do: where(query, ^do_apply_tags(tags))

  @spec do_apply_tags([binary]) :: map
  defp do_apply_tags(tags) do
    Enum.reduce(tags, dynamic(false), fn tag, dynamic ->
      itag = String.downcase(tag)
      dynamic([p], ^dynamic or ^itag in p.tags)
    end)
  end

  @spec apply_contains(Ecto.Query.t(), nil | binary) :: Ecto.Query.t()
  defp apply_contains(query, nil), do: query
  defp apply_contains(query, contains), do: where(query, ^do_apply_contains(contains))

  @spec do_apply_contains(binary) :: map
  defp do_apply_contains(contains) do
    sanitized_contains = String.trim(contains) |> String.replace(~r/\%/, "")
    query_string = "%#{sanitized_contains}%"

    dynamic(
      [p, _a, sp],
      ilike(p.title, ^query_string) or
        ilike(p.body, ^query_string) or
        ilike(sp.title, ^query_string) or
        ilike(sp.body, ^query_string)
    )
  end

  @spec patch_post(Ecto.UUID.t(), map) :: {:ok, Post.t()} | {:error, term}
  def patch_post(id, params) do
    # Note: Optimally this would be done with locking the table or a transaction
    case Repo.get(Post, id) do
      nil -> {:error, :not_found}
      post -> do_patch_post(post, params)
    end
  end

  @spec do_patch_post(Post.t(), map) :: {:ok, Post.t()} | {:error, term}
  defp do_patch_post(post, params) do
    changeset = Post.patch_changeset(post, params)
    Repo.update(changeset)
  end

  @spec delete_post(Ecto.UUID.t()) :: {:ok, Post.t()} | {:error, term}
  def delete_post(id), do: patch_post(id, %{is_deleted: true})
end
