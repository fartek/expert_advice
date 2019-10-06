defmodule ExpertAdviceStorage.IdentityTest do
  use ExpertAdviceStorage.DataCase

  alias ExpertAdviceStorage.Factory
  alias ExpertAdviceStorage.Identity

  setup do
    account = Factory.insert!(:account)
    user = Factory.insert!(:user, account_id: account.id)

    %{
      valid_params: %{account_id: account.id, user_id: user.id, username: account.username},
      account: account,
      user: user
    }
  end

  describe "get_account/1" do
    test "returns the account with preloaded user if found by id", context do
      account = Identity.get_account(context.valid_params.account_id)
      refute is_nil(account)
      assert account.user.id == context.valid_params.user_id
    end

    test "returns nil if not found" do
      invalid_id = Ecto.UUID.generate()
      assert invalid_id |> Identity.get_account() |> is_nil()
    end
  end

  describe "get_account_by_username/1" do
    test "returns the account with preloaded user if found by username", context do
      account = Identity.get_account_by_username(context.valid_params.username)
      refute is_nil(account)
      assert account.user.id == context.valid_params.user_id
    end

    test "returns nil if not found" do
      assert "invalid_username" |> Identity.get_account_by_username() |> is_nil()
    end
  end

  describe "create_account_and_user/1" do
    test "returns error changeset if fails on inserting account" do
      assert {:error, changeset} = Identity.create_account_and_user(%{})
      assert changeset.valid? == false
    end

    test "returns error changeset if fails on inserting user" do
      params = %{username: "unique_user", password: "correct_password"}
      assert {:error, changeset} = Identity.create_account_and_user(params)
      assert changeset.valid? == false
    end
  end
end
