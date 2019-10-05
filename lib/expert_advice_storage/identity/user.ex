defmodule ExpertAdviceStorage.Identity.User do
  @moduledoc """
  The schema module for users
  """

  use Ecto.Schema

  alias __MODULE__
  alias Ecto.Changeset
  alias ExpertAdviceStorage.Board.Post
  alias ExpertAdviceStorage.Identity.Account

  @allowed_fields ~w(display_name account_id)a
  @required_fields ~w(display_name account_id)a

  @type t :: %User{display_name: binary}

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users" do
    field(:display_name, :string)

    belongs_to(:account, Account, type: Ecto.UUID)
    has_one(:post, Post, foreign_key: :author_id)

    timestamps()
  end

  @spec changeset(map) :: Changeset.t()
  def changeset(params) do
    %User{}
    |> Changeset.cast(params, @allowed_fields)
    |> Changeset.validate_required(@required_fields)
    |> Changeset.unique_constraint(:display_name)
  end
end
