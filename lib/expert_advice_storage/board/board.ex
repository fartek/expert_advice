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

  @spec get_post_with_subposts_by_slug(binary) :: {:ok, Post.t()} | {:error, term}
  def get_post_with_subposts_by_slug(slug) do
    Post
    |> where([p], p.slug == ^slug)
    |> join(:left, [p], assoc(p, :subposts))
    |> preload([_, sp], subposts: sp)
    |> order_by([_, sp], asc: sp.inserted_at)
    |> Repo.one()
  end

  @typep criterion :: {:tags, [binary]} | {:contains, binary} | {:limit, pos_integer}
  @spec list_root_posts([criterion]) :: [Post.t()]
  def list_root_posts(criteria \\ []) do
    tags = criteria[:tags]
    contains = criteria[:contains]
    limit = criteria[:limit]

    Post
    |> where([p], is_nil(p.parent_id))
    |> join(:left, [p], assoc(p, :subposts))
    |> preload([_, sp], subposts: sp)
    |> apply_tags(tags)
    |> apply_contains(contains)
    |> apply_limit(limit)
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
      [p, sp],
      ilike(p.title, ^query_string) or
        ilike(p.body, ^query_string) or
        ilike(sp.title, ^query_string) or
        ilike(sp.body, ^query_string)
    )
  end
end
