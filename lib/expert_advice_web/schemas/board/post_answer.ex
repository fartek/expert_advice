defmodule ExpertAdviceWeb.Schemas.Board.PostAnswer do
  @moduledoc """
  This schema is used to validate user input when posting an answer
  """
  use Ecto.Schema

  alias __MODULE__
  alias Ecto.Changeset

  @allowed_fields ~w(content)a
  @required_fields ~w(content)a

  embedded_schema do
    field(:content, :string, label: "Answer")
  end

  @spec changeset(map) :: Changeset.t()
  def changeset(params \\ %{}) do
    %PostAnswer{}
    |> Changeset.cast(params, @allowed_fields)
    |> Changeset.validate_required(@required_fields)
    |> Changeset.validate_length(:content, max: 2500)
  end

  @spec extract_errors(Changeset.t()) :: map
  def extract_errors(%{valid?: false} = changeset) do
    Changeset.traverse_errors(changeset, & &1)
  end

  def extract_errors(changeset), do: changeset
end
