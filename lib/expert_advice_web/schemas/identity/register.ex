defmodule ExpertAdviceWeb.Schemas.Identity.Register do
  @moduledoc """
  This schema is used to validate user input when registering
  """
  use Ecto.Schema

  alias __MODULE__
  alias Ecto.Changeset

  @allowed_fields ~w(username display_name password password_confirmation)a
  @required_fields ~w(username display_name password password_confirmation)a

  embedded_schema do
    field(:username, :string)
    field(:display_name, :string)
    field(:password, :string)
    field(:password_confirmation, :string)
  end

  @spec changeset(map) :: Changeset.t()
  def changeset(params \\ %{}) do
    %Register{}
    |> Changeset.cast(params, @allowed_fields)
    |> Changeset.validate_required(@required_fields)
    |> Changeset.validate_confirmation(:password,
      message: "The confirmation must match the original password"
    )
  end

  @spec merge_with_changeset(Changeset.t(), Changeset.t()) :: Changeset.t()
  def merge_with_changeset(schema, changeset) do
    schema
    |> Map.put(:changes, Map.merge(schema.changes, changeset.changes))
    |> Map.put(:errors, schema.errors ++ changeset.errors)
    |> Map.put(:valid?, schema.valid? and changeset.valid?)
    |> Map.put(:action, changeset.action)
  end
end
