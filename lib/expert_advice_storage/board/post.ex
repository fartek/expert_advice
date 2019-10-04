defmodule ExpertAdviceStorage.Board.Post do
  @moduledoc """
  The schema module for posts
  """

  use Ecto.Schema

  alias __MODULE__
  alias Ecto.Changeset

  @allowed_fields ~w(title body tags parent_id)a
  @required_fields ~w(title body tags)a

  @type t :: %Post{
          title: binary,
          slug: binary,
          body: binary,
          tags: [binary]
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "posts" do
    field(:title, :string)
    field(:slug, :string)
    field(:body, :string)
    field(:tags, {:array, :string})

    has_many(:subposts, Post, foreign_key: :parent_id)
    belongs_to(:post, Post, type: Ecto.UUID, foreign_key: :parent_id)

    timestamps()
  end

  @spec changeset(map) :: Changeset.t()
  def changeset(params) do
    %Post{}
    |> Changeset.cast(params, @allowed_fields)
    |> Changeset.validate_required(@required_fields)
    |> Changeset.unique_constraint(:title)
    |> Changeset.unique_constraint(:slug)
    |> generate_slug()
  end

  @spec generate_slug(Changeset.t()) :: Changeset.t()
  defp generate_slug(%Changeset{valid?: true, changes: %{title: title}} = changeset) do
    case Slug.slugify(title) do
      nil -> Changeset.add_error(changeset, :title, "must contain only url-safe characters")
      slug -> Changeset.change(changeset, slug: slug)
    end
  end

  defp generate_slug(changeset), do: changeset
end
