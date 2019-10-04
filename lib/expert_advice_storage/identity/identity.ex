defmodule ExpertAdviceStorage.Identity do
  @moduledoc """
  The context module for managing identity on the DB level.
  """

  import Ecto.Query

  alias ExpertAdviceStorage.Repo
  alias ExpertAdviceStorage.Identity.{Account, User}

  @spec create_account(map) :: {:ok, Account.t()} | {:error, term}
  def create_account(params) do
    params
    |> Account.changeset()
    |> Repo.insert()
  end

  @spec create_user(map) :: {:ok, Account.t()} | {:error, term}
  def create_user(params) do
    params
    |> User.changeset()
    |> Repo.insert()
  end

  @spec get_account(Ecto.UUID.t()) :: Account.t() | nil
  def get_account(account_id) do
    Account
    |> join(:inner, [a], assoc(a, :user))
    |> preload([_, u], user: u)
    |> Repo.get(account_id)
  end

  @spec get_account_by_username(binary) :: Account.t() | nil
  def get_account_by_username(username) do
    Account
    |> where([a], a.username == ^username)
    |> join(:inner, [a], assoc(a, :user))
    |> preload([_, u], user: u)
    |> Repo.one()
  end
end
