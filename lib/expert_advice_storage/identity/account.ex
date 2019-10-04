defmodule ExpertAdviceStorage.Identity.Account do
  @moduledoc """
  The schema module for accounts
  """

  use Ecto.Schema

  alias __MODULE__
  alias Ecto.Changeset
  alias ExpertAdviceStorage.Identity.User

  @allowed_fields ~w(username password)a
  @required_fields ~w(username password)a

  @type t :: %Account{
          username: binary,
          password: binary,
          hashed_password: binary
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "accounts" do
    field(:username, :string)
    field(:password, :string, virtual: true)
    field(:hashed_password, :string)

    has_one(:user, User)

    timestamps()
  end

  @spec changeset(map) :: Changeset.t()
  def changeset(params) do
    %Account{}
    |> Changeset.cast(params, @allowed_fields)
    |> Changeset.validate_required(@required_fields)
    |> Changeset.unique_constraint(:username)
    |> put_hashed_password()
    |> remove_password()
  end

  @spec put_hashed_password(Changeset.t()) :: Changeset.t()
  defp put_hashed_password(%Changeset{valid?: true, changes: %{password: password}} = changeset) do
    Changeset.change(changeset, hashed_password: Pbkdf2.hash_pwd_salt(password))
  end

  defp put_hashed_password(changeset), do: changeset

  @spec remove_password(Changeset.t()) :: Changeset.t()
  defp remove_password(changeset), do: Changeset.delete_change(changeset, :password)
end
