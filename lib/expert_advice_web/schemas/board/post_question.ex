defmodule ExpertAdviceWeb.Schemas.Board.PostQuestion do
  @moduledoc """
  This schema is used to validate user input when posting a question
  """
  use Ecto.Schema

  alias __MODULE__
  alias Ecto.Changeset

  @allowed_fields ~w(title content tags)a
  @required_fields ~w(title content)a

  embedded_schema do
    field(:title, :string)
    field(:content, :string)
    field(:tags, :string)
  end

  @spec changeset(map) :: Changeset.t()
  def changeset(params \\ %{}) do
    %PostQuestion{}
    |> Changeset.cast(params, @allowed_fields)
    |> Changeset.validate_required(@required_fields)
    |> Changeset.validate_length(:content, max: 2500)
    |> tags_string_to_list()
    |> Changeset.validate_length(:tags, max: 5)
  end

  @spec tags_string_to_list(Changeset.t()) :: Changeset.t()
  defp tags_string_to_list(%{valid?: true, changes: %{tags: tags}} = changeset) do
    tags_list =
      tags
      |> String.split(",")
      |> Stream.map(&String.trim(&1))
      |> Stream.reject(&(&1 == ""))
      |> Stream.map(&Regex.replace(~r/\W+/, &1, "_"))
      |> Enum.to_list()

    Changeset.change(changeset, %{tags: tags_list})
  end

  defp tags_string_to_list(changeset), do: changeset

  @spec with_tag_list_to_string(Changeset.t()) :: Changeset.t()
  def with_tag_list_to_string(%{changes: %{tags: tags}} = changeset) do
    tags_string = Enum.join(tags, ", ")
    Changeset.change(changeset, %{tags: tags_string})
  end

  def with_tag_list_to_string(changeset), do: changeset

  @spec merge_with_changeset(Changeset.t(), Changeset.t()) :: Changeset.t()
  def merge_with_changeset(schema, changeset) do
    schema
    |> Map.put(:changes, Map.merge(schema.changes, changeset.changes))
    |> Map.put(:errors, schema.errors ++ changeset.errors)
    |> Map.put(:valid?, schema.valid? and changeset.valid?)
    |> Map.put(:action, changeset.action)
  end
end
