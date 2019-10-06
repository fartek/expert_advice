defmodule ExpertAdvice.Identity do
  @moduledoc """
  The domain logic module for managing identity
  """
  alias ExpertAdviceStorage.Identity, as: IdentityStorage
  alias ExpertAdviceStorage.Identity.Account

  @spec register(map) :: :ok | {:error, term}
  def register(params), do: IdentityStorage.create_account_and_user(params)

  @typep auth_success :: {:ok, Account.t()}
  @typep auth_error :: {:error, :invalid_credentials}
  @spec authenticate(binary, binary) :: auth_success | auth_error
  def authenticate(username, password) do
    username
    |> IdentityStorage.get_account_by_username()
    |> do_authenticate(password)
  end

  @spec do_authenticate(Account.t() | nil, binary) :: auth_success | auth_error
  defp do_authenticate(nil, _) do
    Pbkdf2.no_user_verify()
    {:error, :invalid_credentials}
  end

  defp do_authenticate(account, password) do
    if Pbkdf2.verify_pass(password, account.hashed_password) do
      {:ok, account}
    else
      {:error, :invalid_credentials}
    end
  end
end
