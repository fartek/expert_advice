defmodule ExpertAdvice.IdentityTest do
  use ExpertAdviceStorage.DataCase

  alias ExpertAdvice.Identity

  setup do
    %{
      valid_params: %{
        username: "valid_user",
        password: "valid_pass",
        display_name: "valid_display_name"
      }
    }
  end

  describe "register/1" do
    test "returns :ok when successful", context do
      assert Identity.register(context.valid_params) == :ok
    end

    test "returns an error tuple when fails", context do
      params = Map.delete(context.valid_params, :display_name)
      assert {:error, changeset} = Identity.register(params)
      assert changeset.valid? == false
    end
  end

  describe "authenticate/2" do
    test "returns the account if successful", context do
      ExpertAdviceStorage.Identity.create_account_and_user(context.valid_params)
      username = context.valid_params.username
      password = context.valid_params.password

      assert {:ok, account} = Identity.authenticate(username, password)
      assert account.username == username
    end

    test "returns an error tuple if fails" do
      assert Identity.authenticate("random", "random") == {:error, :invalid_credentials}
    end
  end
end
