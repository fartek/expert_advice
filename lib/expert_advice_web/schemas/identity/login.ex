defmodule ExpertAdviceWeb.Schemas.Identity.Login do
  @moduledoc """
  This schema is used to validate user input when logging in
  """
  use Ecto.Schema

  alias __MODULE__
  alias Ecto.Changeset

  @allowed_fields ~w(username password)a
  @required_fields ~w(username password)a

  embedded_schema do
    field(:username, :string)
    field(:password, :string)
  end

  @spec changeset(map) :: Changeset.t()
  def changeset(params \\ %{}) do
    %Login{}
    |> Changeset.cast(params, @allowed_fields)
    |> Changeset.validate_required(@required_fields)
  end
end
