defmodule ExpertAdviceStorage.Identity.AccountTest do
  use ExpertAdviceStorage.DataCase

  alias ExpertAdviceStorage.Factory
  alias ExpertAdviceStorage.Identity.Account

  setup do
    %{
      valid_params: %{
        username: "valid_user",
        password: "valid_pass"
      }
    }
  end

  describe "changeset/1" do
    test "creates a valid changeset for valid params", context do
      changeset = Account.changeset(context.valid_params)
      assert changeset.valid?
      assert changeset.changes.username == "valid_user"
    end

    test "generates a hashed password", context do
      changeset = Account.changeset(context.valid_params)
      assert Pbkdf2.verify_pass("valid_pass", changeset.changes.hashed_password)
    end

    test "removes the password change", context do
      changeset = Account.changeset(context.valid_params)
      refute Map.has_key?(changeset.changes, :password)
    end

    test "throws away non-allowed properties", context do
      params = Map.put(context.valid_params, :random_param, "value")
      refute params |> Account.changeset() |> Map.has_key?(:random_param)
    end

    test "requires specific properties", context do
      params_no_username = Map.delete(context.valid_params, :username)
      params_no_password = Map.delete(context.valid_params, :password)

      refute Account.changeset(params_no_username).valid?
      refute Account.changeset(params_no_password).valid?
    end

    test "assures no duplicate usernames are created", context do
      Factory.insert!(:account, username: "valid_user")

      assert {:error, changeset} = context.valid_params |> Account.changeset() |> Repo.insert()
      errors = Changeset.traverse_errors(changeset, & &1)
      assert %{username: [{"has already been taken", _}]} = errors
    end
  end
end
