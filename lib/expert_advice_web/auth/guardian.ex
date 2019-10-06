defmodule ExpertAdviceWeb.Auth.Guardian do
  @moduledoc """
  The Guardian authentication callbacks module.
  This is mostly copy-pasted from https://github.com/ueberauth/guardian
  guides due to time constraints.
  A refactor should address this with typespecs etc. 😬
  """
  use Guardian, otp_app: :expert_advice

  alias ExpertAdviceStorage.Identity

  def subject_for_token(account, _claims) do
    {:ok, to_string(account.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    case Identity.get_account(id) do
      nil -> {:error, :resource_not_found}
      account -> {:ok, account}
    end
  end
end
